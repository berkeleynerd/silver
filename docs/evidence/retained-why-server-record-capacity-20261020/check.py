#!/usr/bin/env python3
"""Check retained identities, exact source slices and protocol/output arithmetic.

No target execution; the research note owns the control/semantic argument.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CAPTURE = "docs/evidence/retained-why-save-state-capture-20261020/"
WHY = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
OCAML = "docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz"
OCAML_PREFIX = "ocaml-8eb41f72ded84df884c3671734c947f612091f84/"
SLICES = {
    "src/server/server-unix.c": [(49, 49), (86, 90), (132, 142), (234, 245), (303, 311), (313, 409), (414, 545), (547, 592), (615, 628)],
    "src/server/request.c": [(21, 127), (174, 191)],
    "src/server/readbuf.c": [(18, 48)],
    "src/server/writebuf.c": [(17, 70)],
    "src/driver/prove_client.ml": [(75, 113), (161, 215), (230, 261)],
    "src/driver/call_provers.ml": [(168, 174), (392, 429), (448, 498), (507, 531), (542, 560), (601, 618)],
    "src/driver/driver.ml": [(292, 308), (416, 473)],
    "src/driver/whyconf.ml": [(247, 255)],
    "src/core/ident.ml": [(307, 351)],
    "src/util/sysutil.ml": [(29, 39)],
    "src/util/strings.ml": [(19, 48)],
    "src/gnat/gnat_config.ml": [(24, 37), (110, 129), (347, 380), (567, 575), (629, 656), (673, 673)],
    "src/gnat/gnat_checks.ml": [(1049, 1083)],
    "src/gnat/gnat_util.ml": [(101, 108)],
    "src/gnat/gnat_scheduler.ml": [(1, 28)],
    "src/session/controller_itp.ml": [(412, 420), (448, 455), (517, 535)],
}


def identity(b):
    return {"bytes": len(b), "sha256": hashlib.sha256(b).hexdigest()}


def parse_json(b):
    return json.loads(b)


def guards(b, e):
    length = b + e
    index = 3 * e + 2
    total = 1000000010 + length + 1
    scan = (3 * e + 1) * total
    return [length + 79 <= 1000000010,
            scan + length + 79 <= 2**62 - 1,
            4 * index + 2 <= 2**62 - 1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    inputs = parse_json((HERE / "inputs.json").read_bytes())
    for path, expected in inputs["files"].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    witnesses = []
    sources = {}
    for archive, members in [(WHY, {"why3/" + k: v for k, v in SLICES.items()}),
                             (OCAML, {OCAML_PREFIX + "stdlib/filename.ml": [(116, 118), (331, 360)]})]:
        with tarfile.open(ROOT / archive) as tar:
            for member, spans in members.items():
                body = tar.extractfile(member).read()
                sources[member] = body.decode()
                lines = body.decode().splitlines(keepends=True)
                ranges = []
                for first, last in spans:
                    assert 1 <= first <= last <= len(lines), (member, first, last, len(lines))
                    excerpt = "".join(lines[first - 1:last])
                    ranges.append({"first": first, "last": last, "text": excerpt,
                                   **identity(excerpt.encode())})
                witnesses.append({"archive": archive, "member": member,
                                  **identity(body), "ranges": ranges})
    server = sources["why3/src/server/server-unix.c"]
    assert 'len += strlen(id) + 3;' in server and 'len += 27;' in server
    assert 'len+= strlen(outfile) + 1;' in server
    assert 'used = snprintf(msgbuf, len, "F;%s;%d;%.6f;%d;%s\\n",' in server
    assert 'if (used >= len)' in server
    assert 'RLIMIT_FSIZE' not in server
    assert 'execvp(cmd,unix_argv);' in server
    assert 'dup2(outfile, 1);' in server and 'dup2(outfile, 2);' in server
    assert 'Buffer.add_subbytes buf buff 0 !n' in sources['why3/src/util/sysutil.ml']
    manifest = parse_json((ROOT / CAPTURE / "capture-manifest.json").read_bytes())
    prefix = parse_json((ROOT / "docs/evidence/retained-why-path-initial-state-20261020/prefix-attachment.json").read_bytes())
    prefix = {x["case"]: x for x in prefix}
    transfer = parse_json((ROOT / "docs/evidence/retained-why-standard-json-inputs-20261020/transfer.json").read_bytes())
    transfer = {x["case"]: x for x in transfer["cases"]}
    outer = parse_json((ROOT / "docs/evidence/retained-why-diagnostic-expansion-20261020/result.json").read_bytes())
    outer = {x["case"]: x for x in outer["cases"]}
    rows = []
    common_witnesses = []
    with tarfile.open(ROOT / CAPTURE / "capture-common.tar.gz") as common:
        for group in manifest["groups"]:
            phase = group["prefix"]
            plan_b = common.extractfile(phase + "/plan.json").read()
            assert identity(plan_b) == group["plan_identity"]
            plan = parse_json(plan_b)
            run_b = common.extractfile(phase + "/run.py").read()
            assert "cwd=server_spec['cwd']" in run_b.decode()
            for member in [phase + "/plan.json", phase + "/run.py"]:
                common_witnesses.append({"member": member, **identity(common.extractfile(member).read())})
            for filename, template in [("alt_ergo_gnatprove_smt2.drv", "%f-%t-%g.psmt2"),
                                       ("z3_gnatprove.drv", "%f-%t-%g.smt2"),
                                       ("silver_cvc5_no_steps.gen", "%f-%t-%g.smt2")]:
                member = phase + "/overlay/" + filename
                body = common.extractfile(member).read()
                assert ('filename "' + template + '"').encode() in body
                common_witnesses.append({"member": member, "filename_template": template,
                                         **identity(body)})
            for case in group["cases"]:
                name = case["name"]
                spec = next(x for x in plan["inputs"] if x["name"] == name)
                with tarfile.open(ROOT / CAPTURE / case["archive"]) as tar:
                    base = case["member_prefix"]
                    process_b = tar.extractfile(base + "/capture/process.json").read()
                    server_b = tar.extractfile(base + "/capture/server.json").read()
                    config_b = tar.extractfile(base + "/why3.conf").read()
                process = parse_json(process_b)
                observed = parse_json(server_b)
                assert process["pid"] == case["pid"] == prefix[name]["pid"]
                assert process["argv"] == spec["argv"] == prefix[name]["argv"]
                assert process["environment"] == spec["environment"] == prefix[name]["environment"]
                assert observed["actual_argv"] == spec["server"]["argv"]
                assert observed["actual_environment"] == spec["server"]["environment"]
                assert observed["binary"] == plan["server_identity"]
                assert observed["actual_environment"] == {"PATH": "/usr/bin:/bin", "LC_ALL": "C"}
                argv = spec["argv"]
                assert argv[argv.index("--steps") + 1] == "0"
                assert argv[argv.index("--timeout") + 1] == "0"
                assert "--memlimit" not in argv
                assert "-j" not in argv
                assert b"memlimit =  0" in config_b
                commands = {}
                for section in config_b.decode().split("[prover]")[1:]:
                    shortcut = re.search(r'^shortcut = "(.*)"$', section, re.M)
                    if shortcut and shortcut[1] in ["cvc5", "z3", "altergo"]:
                        commands[shortcut[1]] = re.search(r'^command = "(.*)"$', section, re.M)[1]
                assert commands == {
                    "altergo": "alt-ergo --max-split 5 --disable-weaks %f",
                    "cvc5": "cvc5 --prenex-quant=none --stats-internal %f",
                    "z3": "z3 -smt2 -st smt.arith.solver=6 %f"}
                cwd = spec["server"]["cwd"]
                assert all(x not in cwd for x in "\x00\n;")
                assert all(x not in process["environment"]["TMPDIR"] for x in "\x00\n;")
                c = len(cwd.encode())
                # Signed63 decimal includes its minimum value's sign.
                id_bytes = max(len(str(-(2**62))), len(str(2**62 - 1)))
                assert id_bytes == 20
                out_bytes = c + len("/why3XXXXXX")
                allocation = id_bytes + out_bytes + 31
                line = allocation - 2  # Remove NUL and terminating LF.
                assert line == c + 60 and allocation <= 2**31 - 1
                t = transfer[name]
                assert t["pid"] == case["pid"]
                a, n = t["conditional_inputs"]["A"], t["conditional_inputs"]["N"]
                raw_id = 20 + 8*n
                partial_line = raw_id + out_bytes + 29
                assert partial_line == c + 60 + 8*n
                assert partial_line + 2 <= 2**31 - 1
                b = t["all_JSON_attempts_coefficients"]["B"]["constant"]
                e = t["all_JSON_attempts_coefficients"]["E"]["constant"]
                assert t["all_JSON_attempts_coefficients"]["B"]["O"] == 3111
                assert t["all_JSON_attempts_coefficients"]["E"]["O"] == 1039
                o = (1000000010 - 79 - b - e) // (3111 + 1039)
                q = o // max(a, n)
                assert all(guards(b + 3111*o, e + 1039*o))
                assert not guards(b + 3111*(o+1), e + 1039*(o+1))[0]
                assert not guards(b + 3111*max(a,n)*(q+1), e + 1039*max(a,n)*(q+1))[0]
                rows.append({"case": name, "pid": case["pid"],
                    "archive": case["archive"], "process_identity": identity(process_b),
                    "server_identity": identity(server_b), "config_identity": identity(config_b),
                    "server_launch": spec["server"], "commands": commands,
                    "C_launch": c, "current_dir_value_observed": False,
                    "line_upper_if_C_is_launch_length": line,
                    "wire_record_upper_if_C_is_launch_length": line+1,
                    "F_allocation_upper_if_C_is_launch_length": allocation,
                    "recv_concatenation_upper_if_C_is_launch_length": line+1024,
                    "InvalidAnswer_direct_text_upper_if_C_is_launch_length": line+len("Invalid server answer: "),
                    "raw_ID_upper_with_abandoned_request_prefixes": raw_id,
                    "prefix_safe_line_upper_if_C_is_launch_length": partial_line,
                    "prefix_safe_recv_concatenation_upper_if_C_is_launch_length": partial_line+1024,
                    "prefix_safe_InvalidAnswer_direct_text_upper_if_C_is_launch_length": partial_line+23,
                    "all_InvalidAnswer_branch_direct_text_upper_conditional":
                        (partial_line+23)*outer[name]["conditional_dispatch_products"]["particular_terminal_matching_branch_attempts_upper"],
                    "source_protocol_message_attempts_upper": n,
                    "extra_interrupt_or_parallel_message_attempts_under_selected_roots": 0,
                    "R": t["conditional_inputs"]["R"], "G": t["conditional_inputs"]["G"],
                    "A": a, "N": n, "JSON_B_constant": b, "JSON_E_constant": e,
                    "optimistic_O_guard_ceiling": o, "optimistic_uniform_q_guard_ceiling": q,
                    "actual_O": None, "actual_solver_file_upper": None,
                    "server_receive_preservation_attached": False,
                    "pinned_solver_executable_resolution_attached": False})
    # Construct an interface family, not a claimed execution of a pinned solver.
    k = 30080
    payload = b"unknown\n" * k
    parts = [payload[i:i+1024] for i in range(0, len(payload), 1024)]
    assert max(map(len, parts)) <= 1024 and b"".join(parts) == payload
    assert len(payload) > rows[0]["optimistic_O_guard_ceiling"]
    countermodel = {"domain": "unconstrained solver-output receiver interface only",
        "pattern": "unknown\\n", "repetitions": k, "file_bytes": len(payload),
        "chunks": len(parts), "largest_chunk": max(map(len, parts)),
        "consecutive_Unknown_join_payload_bytes": 10*k-3,
        "pinned_solver_execution_claimed": False,
        "actual_guard_failure_claimed": False,
        "meaning": "1024-byte chunks do not imply a total output bound; the imported sufficient envelope cannot certify this O even with other unknown inputs zero."}
    # Two prefixes of selected request shapes; no target C/OCaml is executed.
    splice = b"run;1" + b"run;2;0;0;solver;input.smt2\n"
    fields = splice.rstrip(b"\n").split(b";")
    assert fields[:2] == [b"run", b"1run"]
    assert not fields[1].isdigit()
    splice_model = {"received": splice.decode(), "raw_server_id": fields[1].decode(),
                    "decimal_ID_preservation": False, "pinned_native_execution_claimed": False}
    assert 'memcpy(b->data, b->data+size, b->len - size);' in sources['why3/src/server/readbuf.c']
    filename = rows[0]['server_launch']['cwd'] + '/temp/why_000000_x-T-x.smt2'
    first = ('run;1;0;0;z3;-smt2;-st;smt.arith.solver=6;' + filename + '\n').encode()
    second = ('run;2;0;0;cvc5;--prenex-quant=none;--stats-internal;' + filename + '\n').encode()
    retained = len(first) + 1
    assert retained < len(second) and len(first) + retained <= 1024
    assert b'\n' not in second[:retained]
    overlap = {"scope": "protocol-shape witness using selected command tokens and an allowed sanitized filename; not an actual captured request sequence",
               "first_request_bytes": len(first), "partial_next_request_bytes": retained,
               "read_bytes": len(first)+retained, "copy_size": retained,
               "source_interval": [len(first), len(first)+retained],
               "destination_interval": [0, retained],
               "overlap_bytes": retained-len(first),
               "ordinary_memcpy_precondition_holds": False,
               "installed_native_misbehavior_claimed": False}
    products = {"source-witnesses.json": witnesses,
                "attachment.json": {"common_members": common_witnesses, "cases": rows},
                "result.json": {"cases": len(rows), "line_formula_excluding_LF": "C+60",
                    "F_allocation_formula": "C+62", "pending_plus_read_formula": "C+1084",
                    "InvalidAnswer_direct_text_formula": "C+83",
                    "prefix_safe_line_formula_excluding_LF": "C+60+8N",
                    "prefix_safe_raw_ID_formula": "20+8N",
                    "generic_offered_request_Q_line_formula_excluding_LF": "Q+C+40",
                    "weighted_O_formula_from_proved_uniform_q": "max(A,N)*q",
                    "F_success_scalar_guard": "decimal_exit_bytes + fixed6_cpu_time_bytes <= 22",
                    "countermodel": countermodel, "request_splice_countermodel": splice_model,
                    "server_memcpy_overlap_witness": overlap, "actual_O": None,
                    "server_receive_preservation_attached": False,
                    "protocol_liveness_established": False, "complete_server_capacity": False,
                    "whole_JSON_B_E": None, "complete_R": False, "complete_U": False,
                    "issue_119_or_153_complete": False, "new_target_runs": 0,
                    "solver_runs": 0, "proof_runs": 0, "source_fetches": 0,
                    "predecessor_checker_replays": 0}}
    for filename, obj in products.items():
        encoded = (json.dumps(obj, indent=2, sort_keys=True) + "\n").encode()
        if args.write:
            (HERE / filename).write_bytes(encoded)
        else:
            assert (HERE / filename).read_bytes() == encoded, filename
    print("PASS: retained sources/configurations, five protocol/output interfaces, exact guard arithmetic")


if __name__ == "__main__":
    main()
