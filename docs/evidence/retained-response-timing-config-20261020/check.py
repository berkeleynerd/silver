#!/usr/bin/env python3
"""Focused offline source/configuration evidence; no target execution."""
from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
OCAML = "docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz"
OCAML_ROOT = "ocaml-8eb41f72ded84df884c3671734c947f612091f84/"
CAP = "docs/evidence/retained-why-save-state-capture-20261020/"
CENSUS = "docs/evidence/retained-solver-task-language-20261020/driver-census.json"
COUNTS = "docs/evidence/retained-why-initial-registration-bound-20261020/result.json"
WARNING = "docs/evidence/retained-why-warning-exclusion-20261020/certificate.json"
ADAPTER = "docs/evidence/retained-solver-response-adapter-20261020/"
ROOTS = ("cvc5_gnatprove.drv", "z3_gnatprove.drv", "alt_ergo_gnatprove_smt2.drv")


def ident(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def encoded(obj):
    return (json.dumps(obj, indent=2, sort_keys=True) + "\n").encode()


def derive():
    files = {WHY, OCAML, CENSUS, COUNTS, WARNING,
             ADAPTER + "loaded-response-directives.json", ADAPTER + "canonical-table.json",
             "src/silver_library_reports.adb", "src/silver_reports.adb"}
    members = {}

    def member(path, name):
        files.add(path)
        with tarfile.open(ROOT / path) as archive:
            raw = archive.extractfile(name).read()
        members[path + ":" + name] = ident(raw)
        return raw

    census = json.loads((ROOT / CENSUS).read_text())["identities"]
    originals, candidates, changed = {}, {}, []
    overlay = {}
    for name, rec in census.items():
        raw = member(rec["archive"], rec["member"])
        assert ident(raw) == rec["identity"]
        originals[name] = raw
        lines = raw.splitlines(keepends=True)
        for i, line in enumerate(lines):
            if re.fullmatch(rb'time "why3cpulimit time : %s s"\n', line):
                # Preserve byte count, every newline, and all subsequent offsets.
                replacement = b"(* time measurement removed  *)\n"
                assert len(replacement) == len(line)
                lines[i] = replacement
                changed.append({"file": name, "line": i + 1, "original_hex": line.hex(),
                                "replacement_hex": replacement.hex(), "bytes": len(line)})
        candidate = b"".join(lines)
        candidates[name] = candidate
        assert len(candidate) == len(raw)
        assert [i for i,b in enumerate(raw) if b == 10] == [i for i,b in enumerate(candidate) if b == 10]
        if rec["private"] or name == "smt-libv2.gen":
            overlay["overlay/" + name] = candidate
    assert {(c["file"],c["line"]) for c in changed} == {
        ("smt-libv2.gen",23), ("alt_ergo_gnatprove_smt2.drv",18)}
    assert len(overlay) == 5

    def project(raw):
        source = re.sub(rb"\(\*.*?\*\)", b"", raw, flags=re.S)
        source = re.sub(rb'^time "why3cpulimit time : %s s"$', b"", source, flags=re.M)
        return re.findall(rb'"(?:[^"\\]|\\.)*"|[^\s]+', source)

    for name in originals:
        assert project(originals[name]) == project(candidates[name]), name

    loaded = json.loads((ROOT / (ADAPTER + "loaded-response-directives.json")).read_text())
    projected = {}
    for name in ROOTS:
        before = loaded[name]
        after = [x for x in before if x["directive"] != "time"]
        assert sum(x["directive"] == "time" for x in before) == (2 if name.startswith("alt_") else 1)
        assert not any(x["directive"] in ("time", "steps") for x in after)
        projected[name] = {"removed_time_rules": len(before)-len(after), "response_rules": after}

    rows, resources, invocations = [], [], []
    cases = json.loads((ROOT / COUNTS).read_text())["cases"]
    for case in cases:
        name = case["case"]
        group = "inline" if name == "input_is_valid" else "registration"
        archive = CAP + "capture-" + name.replace("_", "-") + ".tar.gz"
        prefix = group + "/" + name + "/"
        plan = json.loads(member(CAP+"capture-common.tar.gz", group+"/plan.json"))
        invocation = next(i for i in plan["inputs"] if i["name"] == name)
        process = json.loads(member(archive, prefix+"capture/process.json"))
        summary = json.loads(member(archive, prefix+"capture/summary.json"))
        base = member(archive, prefix+"why3.conf")
        extra = member(CAP+"capture-common.tar.gz", group+"/overlay/why3.conf")
        assert ident(base)["sha256"] == "f83746bab113aeaa0d1b3ccfd13a2ce0cd965f2673ac89b84973fd4b121dd1fb"
        assert extra == b"[main]\nmagic = 14\n"
        overlay["overlay/why3.conf"] = extra
        overlay["base-why3.conf"] = base
        assert process["pid"] == case["pid"]
        assert process["argv"] == invocation["argv"] and process["environment"] == invocation["environment"]
        args = invocation["argv"]
        for flag, value in [("--steps","0"),("--timeout","0"),("--counterexample","off"),
                            ("--proof","per_check"),("--prover","cvc5,z3,altergo")]:
            assert args[args.index(flag)+1] == value
        assert "--memlimit" not in args and "--warn-timeout" not in args and "--replay" not in args
        assert "-j" not in args
        assert invocation["server"]["argv"][-2:] == ["-j","1"]
        assert invocation["environment"]["OCAMLRUNPARAM"] == "s=256M,h=16M,M=1000"
        extra_path = args[args.index("--why3-conf")+1]
        old_path = plan["installed_driver_directory"] + "/smt-libv2.gen"
        new_path = str(Path(extra_path).parent / "smt-libv2.gen")
        assert len(new_path) < len(old_path)
        assert plan["file_identities"][old_path] == ident(originals["smt-libv2.gen"])
        assert summary["completed"] and not summary["failures"] and not summary["guard_hits"]
        assert not summary["new_threads"] and process["initial_threads"] == 1
        start = summary["baseline"]
        end = next(s for s in summary["snapshots"] if s["label"] == case["endpoint"])
        assert start["label"] == "before_first_why3_module"
        stats = ["stat_minor_words","stat_major_words","stat_promoted_words","stat_minor_collections",
                 "stat_major_collections","stat_compactions","stat_forced_major_collections"]
        for snap in (start,end):
            s = snap["state"]
            assert snap["native_r14"] == snap["state_address"]
            assert snap["minor_allocated_words"] == (s["young_alloc_end"]-snap["effective_young_ptr"])//8
            assert s["young_limit"] == s["young_trigger"] == s["young_alloc_start"]
            assert s["young_alloc_end"]-s["young_alloc_start"] == 8*2**28
            assert s["minor_heap_wsz"] == snap["caml_init_minor_heap_wsz"] == 2**28
            assert snap["caml_init_heap_wsz"] == s["stat_heap_wsz"] == 2**24
            assert s["stat_heap_chunks"] == 1 and s["stat_major_collections"] == 0
            assert snap["caml_custom_major_ratio"] == 1000 and snap["caml_gc_phase"] == 0
            assert all(s[k] == 0 for k in ("in_minor_collection","requested_major_slice","requested_minor_gc"))
            assert 0 <= s["extra_heap_resources_minor"] < 1
            assert 0 <= snap["caml_extra_heap_resources"] < 1
            assert snap["caml_dependent_size"] == snap["caml_dependent_allocated"] == 0
            assert all(s[k] == start["state"][k] for k in stats)
            for table in snap["tables"].values():
                assert table["used_entries"] == (table["ptr"]-table["base"])//table["entry_size"]
                assert table["ptr"] < table["threshold"] == table["limit"]
                assert (table["threshold"]-table["base"])//table["entry_size"] == 2**25
        assert end["minor_allocated_words"] == case["minor_allocated_words"]
        resources.append({"case":name,"pid":process["pid"],"start":start,"end":end})
        invocations.append({"case":name,"invocation":invocation,"base_config":ident(base),"extra_config":ident(extra),
                            "old_import_path":old_path,"candidate_import_path":new_path})
        rows.append({"case":name,"cut":case["endpoint"],"minor":end["minor_allocated_words"],
                     "major":end["caml_allocated_words"],"tables":{k:v["used_entries"] for k,v in end["tables"].items()},
                     "prior_major_words":end["state"]["stat_major_words"],
                     "I":case["initial_registration_count"]})

    # Source-derived conservative credits: ALL candidate FileTags activity,
    # plus a fixed lexer/parser/closure allowance; not the quiet-command delta.
    baseline_major = max(row["major"] for row in rows)
    assert baseline_major == 945213
    file_names_upper = baseline_major + 1
    delta_minor = delta_major = 8 * file_names_upper + 16384
    reference_credit = 20 * file_names_upper + 16384
    for row in rows:
        row["candidate_minor_upper"] = row["minor"] + delta_minor
        row["candidate_major_upper"] = row["major"] + delta_major
        row["candidate_arena_allocation_upper"] = row["candidate_major_upper"] + row["prior_major_words"]
        row["candidate_reference_upper"] = row["tables"]["ref_table"] + reference_credit
        assert row["candidate_minor_upper"] < 2**28
        assert row["candidate_arena_allocation_upper"] < 2**24
        assert row["candidate_reference_upper"] < 2**25
        assert 5*row["I"] <= row["candidate_minor_upper"] < 5*2**62

    # OCaml's comparison-based min/max, deliberately including NaN/infinity.
    def ocaml_min(x,y): return x if x <= y else y
    def ocaml_max(x,y): return x if x >= y else y
    samples = [-math.inf,-1e308,-1.0,-0.0,0.0,1e-320,1.0,1e308,math.inf,math.nan]
    numeric = []
    for t in samples:
        increased = ocaml_max(0.0, ocaml_min(1.0+2.0*t, 2.0*0.0))
        assert increased == 0 and math.copysign(1,increased) == 1
        numeric.append({"old_time":str(t),"increased_time":increased})
    assert all((max(0, -1-add)//mult+1) == 1 for add,mult in [(15000,35),(450000,800),(0,1)])

    ranges = {
        "src/gnat/gnat_config.ml":[(23,29),(110,129),(176,193),(346,409),(567,575),(586,655)],
        "src/gnat/gnat_util.ml":[(65,108)],
        "src/session/controller_itp.ml":[(114,122),(347,409),(412,431),(469,474),(528,533),(619,652)],
        "src/driver/driver.ml":[(37,49),(58,94),(115,148),(155,195),(207,281),(371,388),(450,494)],
        "src/driver/driver_lexer.mll":[(59,80),(107,144)],
        "src/driver/driver_parser.mly":[(45,77)],
        "src/util/lexlib.mll":[(82,124)],
        "src/driver/call_provers.ml":[(47,55),(82,127),(350,429),(448,458),(507,534)],
        "src/driver/prove_client.ml":[(161,184),(230,247)],
        "src/server/request.c":[(109,124)],
        "src/server/server-unix.c":[(313,398),(434,459),(469,499),(517,524)],
        "src/util/loc.ml":[(18,24),(42,64),(100,112),(254,297)],
        "src/util/wstdlib.ml":[(20,30)],"src/util/exthtbl.ml":[(38,48)],
        "src/core/ident.ml":[(159,191)],"src/core/term.ml":[(325,331),(420,429)],
        "src/gnat/gnat_checks.ml":[(769,826),(961,971),(985,1033),(1049,1084)],
        "src/gnat/gnat_report.ml":[(34,46),(211,233)],
        "src/gnat/gnat_main.ml":[(95,115)],
        "src/session/session_itp.ml":[(1843,1863),(2056,2071)],
    }
    witnesses = []
    for suffix, spans in ranges.items():
        name = "why3/"+suffix
        raw = member(WHY,name); lines = raw.decode().splitlines(keepends=True)
        witnesses.append({"archive":WHY,"member":name,"identity":ident(raw),
                          "ranges":[{"first":a,"last":b,"text":"".join(lines[a-1:b])} for a,b in spans]})
    for suffix, spans in {
        "stdlib/stdlib.ml":[(66,75)],"runtime/compare.c":[(215,227),(334,356)],
        "stdlib/hashtbl.ml":[(21,32),(68,81),(115,152),(354,362),(381,399)],
        "stdlib/lexing.ml":[(64,87),(89,169)],
        "runtime/major_gc.c":[(914,925),(1219,1245)],
        "runtime/memory.c":[(463,497)],
        "runtime/freelist.c":[(109,193),(411,490),(1396,1441),(1504,1559),(1722,1747)],
        "runtime/obj.c":[(184,218)],
    }.items():
        name = OCAML_ROOT+suffix;raw=member(OCAML,name);lines=raw.decode().splitlines(keepends=True)
        witnesses.append({"archive":OCAML,"member":name,"identity":ident(raw),
                          "ranges":[{"first":a,"last":b,"text":"".join(lines[a-1:b])} for a,b in spans]})
    spark_archive = "docs/evidence/unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz"
    spark_member = "spark-source/src/why/gnat2why-error_messages.adb"
    raw = member(spark_archive, spark_member); lines=raw.decode().splitlines(keepends=True)
    witnesses.append({"archive":spark_archive,"member":spark_member,"identity":ident(raw),
                      "ranges":[{"first":1301,"last":1312,"text":"".join(lines[1300:1312])}]})
    inventory = []
    with tarfile.open(ROOT/WHY) as archive:
        for m in archive.getmembers():
            if m.isfile() and m.name.startswith("why3/src/") and m.name.endswith((".ml",".mll")):
                for i,line in enumerate(archive.extractfile(m).read().decode().splitlines(),1):
                    if re.search(r'Loc\.(equal|compare|hash)|FileTags|Re\.Str\.(matched_group|matched_string|group_beginning|group_end|match_beginning|match_end)',line):
                        inventory.append({"member":m.name,"line":i,"text":line})
    api = json.loads((HERE/"re-prefix-source/manifest.json").read_text())
    for name, rec in api["files"].items():
        path=HERE/"re-prefix-source"/name
        assert ident(path.read_bytes()) == {k:rec[k] for k in ("bytes","sha256")}
        files.add(str(path.relative_to(ROOT)))
    files.add(str((HERE/"re-prefix-source/manifest.json").relative_to(ROOT)))
    for name in ["lib/str.ml","lib/emacs.ml","lib/core.ml","manifest.json"]:
        files.add(ADAPTER+"re-api-source/"+name)
    result = {
        "scope":"Five fixed retained serial domains; source/configuration transfer under named runtime/Re relation",
        "configured_limits":[0.0,0,0],"queued_limits":[0.0,0,0],"server_limits":[0,0],
        "warning_attempt_upper":0,"warning_author_freeze":"29e253ba8d4d7905336f137801e4ef6c39718d43",
        "time_measurement_rules_after":0,"steps_measurement_rules_after":0,
        "file_names_upper":file_names_upper,"minor_credit_words":delta_minor,"major_credit_words":delta_major,
        "reference_credit_entries":reference_credit,"rows":rows,"numeric_examples":numeric,
        "semantic_source_argument_machine_checked":False,"new_native_runs":0,"predecessor_replays":0,
        "parallel_transfer_claimed":False,"complete_q":None,"production_adopted":False,
    }
    output = {
        "recipe.json":encoded({"changed_lines":changed,"driver_closure":census,
            "overlay_files":{n:ident(b) for n,b in overlay.items()},"loaded_response_projection":projected}),
        "invocations.json":encoded(invocations),"capture-resources.json":encoded(resources),
        "source-witnesses.json":encoded(witnesses),"consumer-inventory.json":encoded(inventory),
        "result.json":encoded(result),
    }
    output.update(overlay)
    files.add(str(Path(__file__).resolve().relative_to(ROOT)))
    output["inputs.json"] = encoded({"files":{p:ident((ROOT/p).read_bytes()) for p in sorted(files)},
                                     "members":members,"why3_revision":"9390baf120ef260547dfa14f08e11c890b203d9c"})
    return output


def main():
    parser=argparse.ArgumentParser();parser.add_argument("--write",action="store_true");args=parser.parse_args()
    output=derive()
    for name,raw in output.items():
        path=HERE/name
        if args.write:
            path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(raw)
        else:
            assert path.read_bytes() == raw, "evidence differs: "+name
    print(json.dumps({"passed":True,"generated_files":len(output),"native_runs":0,"predecessor_replays":0}))


if __name__ == "__main__":
    main()
