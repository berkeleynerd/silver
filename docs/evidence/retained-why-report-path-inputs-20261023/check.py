#!/usr/bin/env python3
"""Focused retained-input check; no imported predecessor or native program."""
import hashlib
import json
import pathlib
import tarfile
import time

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EVIDENCE = ROOT / "docs/evidence"
WHY = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
OCAML = "docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz"
LIBS = "docs/evidence/retained-producer-import-context-20261018/sources.tar.gz"
OCAML_PREFIX = "ocaml-8eb41f72ded84df884c3671734c947f612091f84/"
ORDER = ["put_line", "put", "first_or_default", "is_message", "input_is_valid"]
EXPECTED = {
    "put_line": (174, 43, 775),
    "put": (171, 82, 802),
    "first_or_default": (189, 49, 841),
    "is_message": (182, 89, 853),
    "input_is_valid": (186, 49, 829),
}
checks = 0
archives = {}


def require(condition, label):
    global checks
    checks += 1
    if not condition:
        raise AssertionError(label)


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def load(path):
    return json.loads(path.read_text())


def dump(name, value):
    (HERE / name).write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def member(archive, name):
    if archive not in archives:
        archives[archive] = tarfile.open(ROOT / archive)
    handle = archives[archive].extractfile(name)
    require(handle is not None, f"regular member {archive}:{name}")
    return handle.read()


def strings(value):
    if isinstance(value, str):
        yield value
    elif isinstance(value, list):
        for child in value:
            yield from strings(child)
    elif isinstance(value, dict):
        for key, child in value.items():
            yield key
            yield from strings(child)


def size(value):
    return len(value.encode("utf-8"))


def native_filename_fields(value):
    """Overapproximate every Source_ptr pair and exact Loc_label marker."""
    filenames, markers = [], []
    if isinstance(value, dict):
        children = value.values()
    elif isinstance(value, list):
        if len(value) == 2 and isinstance(value[0], str) and type(value[1]) is int:
            filenames.append(size(value[0]))
        if value and value[0] == "W_LOC_LABEL":
            require(len(value) == 6 and isinstance(value[-1], str), "exact Loc_label shape")
            markers.append(size(value[-1]))
        children = value
    else:
        children = []
    for child in children:
        fs, ms = native_filename_fields(child)
        filenames.extend(fs)
        markers.extend(ms)
    return filenames, markers


def main():
    start = time.monotonic()
    inputs = load(HERE / "inputs.json")
    for path, expected in inputs.items():
        require(identity((ROOT / path).read_bytes()) == expected, path)
    sources = load(HERE / "source-ranges.json")
    witnesses = []
    for row in sources:
        data = member(row["archive"], row["member"])
        require(identity(data) == row["identity"], row["member"])
        lines = data.decode().splitlines(keepends=True)
        witnesses.append(f"## {row['archive']} :: {row['member']}\n")
        for span in row["ranges"]:
            lo, hi = span["start"], span["end"]
            require(1 <= lo <= hi <= len(lines), f"strict span {row['member']}:{lo}-{hi}")
            text = "".join(lines[lo - 1:hi])
            require(identity(text.encode()) == span["identity"], f"span identity {row['member']}:{lo}-{hi}")
            witnesses.append(f"### Lines {lo}–{hi}\n\n```text\n{text}```\n")
    (HERE / "source-witnesses.md").write_text("# Retained pathname source witnesses\n\n" + "\n".join(witnesses))

    roles = load(EVIDENCE / "retained-parallel-logging-prefix-20261020/input-role-projection.json")
    endpoints = {r["domain"]: r for r in load(EVIDENCE / "retained-shared-server-prefix-20261020/endpoints.json")}
    combined = load(EVIDENCE / "retained-combined-parallel-startup-20261020/projection.json")["domains"]
    request = load(EVIDENCE / "retained-solver-request-bytes-20261020/projection.json")["domains"]
    warning_inputs = load(EVIDENCE / "retained-why-diagnostic-warnings-20261023/inputs.json")
    for path in [WHY, LIBS, "docs/evidence/retained-parallel-logging-prefix-20261020/input-role-projection.json"]:
        require(inputs[path] == warning_inputs[path], f"accepted warning provider join {path}")
    warning_libs = load(EVIDENCE / "retained-why-diagnostic-warnings-20261023/library-projection.json")["initial_files"]
    warning_native = load(EVIDENCE / "retained-why-diagnostic-warnings-20261023/native-projection.json")
    warning_bounds = load(EVIDENCE / "retained-why-diagnostic-warnings-20261023/bounds.json")
    require(len(warning_libs) == 21, "complete initial library count")
    libraries = []
    by_suffix = {}
    for row in warning_libs:
        name = row["member"]
        data = member(LIBS, name)
        require(identity(data) == row["identity"], f"accepted complete library {name}")
        counts = {token.decode(): data.count(token) for token in [b"[#", b"vc:written:", b"call_result:"]}
        require(not any(counts.values()), f"no unchecked library filename producer {name}")
        suffix = name.removeprefix("installed/")
        require(suffix not in by_suffix, f"unique complete suffix {suffix}")
        by_suffix[suffix] = identity(data)
        libraries.append({"member": name, "identity": identity(data), "raw_origin_token_counts": counts})

    domains = {}
    for domain in ORDER:
        cap = roles[domain]["captures"][1]
        archive = cap["archive"]
        require(archive == endpoints[domain]["capture_archive"], f"current J12 archive {domain}")
        for name, expected_hash in cap["members_sha256"].items():
            require(identity(member(archive, name))["sha256"] == expected_hash, f"capture member {name}")
        process_name = next(n for n in cap["members_sha256"] if n.endswith("/process.json"))
        proc = json.loads(member(archive, process_name))
        require(proc["argv"] == cap["argv"], f"actual argv {domain}")
        env = proc["environment"]
        require(set(env) == {"PATH", "LC_ALL", "TMPDIR", "OCAMLRUNPARAM"}, f"complete controlled env {domain}")
        require(env["LC_ALL"] == "C", f"locale {domain}")
        require(env == {k: v.replace("$PRIVATE", cap["private_root"]) for k, v in cap["normalized_environment"].items()}, f"environment role mapping {domain}")
        require(cap["private_root"] == endpoints[domain]["private_root"] == combined[domain]["original_private_root"], f"preserved private root {domain}")
        require(combined[domain]["candidate_argv"] == endpoints[domain]["prospective_argv"], f"combined argv {domain}")
        argv = combined[domain]["candidate_argv"]
        require("--proof-dir" not in argv and "--replay" not in argv, f"fresh relative session {domain}")
        require(argv[argv.index("-j") + 1] == "12" and "--logging" in argv, f"J12 logging {domain}")
        input_arg = proc["argv"][-1]
        require(input_arg == argv[-1] and input_arg.endswith(".gnat-json"), f"input role {domain}")
        input_name = f"{domain}/{input_arg}"
        data = member(archive, input_name)
        opens = cap["ordered_opens"]
        require(len(opens) == 81, f"complete ordered input roles {domain}")
        input_opens = [r for r in opens if r["path"] == input_arg]
        require(len(input_opens) == 1 and input_opens[0]["identity"] == identity(data), f"JSON/open exact identity {domain}")
        tree = json.loads(data)
        values = list(strings(tree))
        require(all(v.isascii() for v in values), f"decoded strings ASCII {domain}")
        raw_location_tokens = {token: sum(token in v for v in values) for token in ["vc:written:", "call_result:", "[#"]}
        require(not any(raw_location_tokens.values()), f"no raw decoded location attribute/directive {domain}")
        filenames, markers = native_filename_fields(tree)
        native_file_max = max(filenames, default=0)
        native_marker_max = max(markers, default=0)
        require(identity(data) == warning_native[domain]["identity"], f"accepted native input identity {domain}")
        require(native_file_max == warning_native[domain]["max_source_filename_bytes"], f"native filename field maximum {domain}")
        require(native_marker_max == warning_native[domain]["max_marker_bytes"], f"native marker field maximum {domain}")
        native_crossed_max = native_file_max + native_marker_max + 4
        require(native_crossed_max <= 27, f"any crossed raw Curr pair {domain}")
        u = max(map(size, values))
        location = 2*u + 4
        tau = size(env["TMPDIR"])
        f_bound = tau + max(5, 2*location) + 28
        require((u, tau, f_bound) == EXPECTED[domain], f"computed U/tau/F {domain}")
        require(env["TMPDIR"] == request[domain]["recorded_TMPDIR"], f"request TMPDIR relation {domain}")
        require(request[domain]["goal_name"] == "def'vc", f"preserved goal header {domain}")
        paths = [r["path"].replace("$PRIVATE", cap["private_root"]) for r in opens]
        resolved = [r["resolved_path"].replace("$PRIVATE", cap["private_root"]) for r in opens]
        maximum_path = max(map(size, paths + resolved))
        require(maximum_path == 180, f"complete initial spelling maximum {domain}")
        private_import = combined[domain]["candidate_private_import"]
        require(size(private_import) == combined[domain]["candidate_private_import_bytes"] <= maximum_path, f"new timeless driver name {domain}")
        matched = []
        for row in opens:
            for suffix, expected_identity in by_suffix.items():
                if row["path"].endswith("/" + suffix):
                    require(row["identity"] == expected_identity, f"current library bytes {domain}:{suffix}")
                    matched.append(row["path"])
        require(len(matched) == 21 and len(set(matched)) == 21, f"complete current library join {domain}")
        require(max(map(size, matched)) == 166, f"library path maximum {domain}")
        require(maximum_path <= location, f"all initial filename origins dominated {domain}")
        stem = input_arg.rsplit(".", 1)[0]
        names = {
            "input": input_arg,
            "session_directory": stem,
            "log": stem + ".why3log",
            "profiling_value": stem + "_gnatwhy3_gmon.out",
            "profiling_error_argument": "GMON_OUT_PREFIX",
            "endpoint": endpoints[domain]["socket"],
        }
        lengths = {k: size(v) for k, v in names.items()}
        lengths["save_backup_upper"] = size(stem) + 20
        require(lengths["endpoint"] == endpoints[domain]["socket_bytes"], f"endpoint bytes {domain}")
        require(max(lengths.values()) <= f_bound, f"configured paths dominated {domain}")
        domains[domain] = {
            "capture_archive": archive,
            "input_member": input_name,
            "input_identity": identity(data),
            "process_member": process_name,
            "decoded_string_count_including_keys": len(values),
            "decoded_string_max_bytes_U": u,
            "decoded_raw_location_token_counts": raw_location_tokens,
            "native_source_filename_upper": native_file_max,
            "native_marker_upper": native_marker_max,
            "native_crossed_filename_marker_upper": native_crossed_max,
            "location_filename_upper_L": location,
            "TMPDIR": env["TMPDIR"],
            "TMPDIR_bytes_tau": tau,
            "request_path_upper_F": f_bound,
            "initial_path_maximum": maximum_path,
            "initial_library_path_maximum": 166,
            "matched_library_paths": matched,
            "new_private_import": private_import,
            "configured_names": names,
            "configured_name_bytes": lengths,
            "P_diag": {"maximum": [f_bound, {"R": 1, "constant": 24}]},
            "M": {"R": 1, "constant": 72},
        }

    require(size("defqtvc") == 7 and 1 + 7 + 2 + 6 == 16, "driver-name overhead")
    require(1 + 4 + 6 + 1 == 12 and 16 + 12 == 28, "temp-name overhead")
    require(size("why3session.xml.bak") + 1 == 20, "save longest suffix")
    require(size("_gnatwhy3_gmon.out") == 18, "profiling value suffix")
    require(len(str(2**62 - 1)) == 19, "positive native ID digits")
    require(1 + 1 + 19 + 1 == 22 and 19 + 29 == 48 and 24 + 48 == 72, "canonical complete-frame coefficients")
    output = {
        "scope": "refined diagnostic pathname operand; all-prefix retained client providers",
        "all_FileTags_filename_upper": 180,
        "alias_robust_warning_filename_upper": 180,
        "alias_robust_warning_entry_upper": 436,
        "domains": domains,
        "actual_R": None,
        "P_stat_actual": None,
        "P_stat_owner": "actual immutable Env.get_loadpath and registered-extension provider for raw path construction/storage",
        "actual_standard_guards": None,
        "actual_channel_guards": None,
        "all_path_storage_capacity_established": False,
        "whole_process_capacity_established": False,
        "admission_changed": False,
        "renewed_failure_budget": False,
        "global_e_upper": 2,
        "save_entering_callbacks_upper": 2,
        "saves_upper": 3,
    }
    dump("projection.json", output)
    dump("library-projection.json", libraries)
    require(warning_bounds["warning_filename_bound"] == 166 and warning_bounds["warning_length_bound"] == 422, "historical warning interface")
    require(180 + 256 == 436 and 436 - 422 == 14, "alias-robust warning amendment")
    warning_rows = []
    for row in warning_bounds["cases"]:
        w = row["W_o"]
        require(row["L_o"] == 422*w, f"historical L_o {row['case']}")
        warning_rows.append({"case": row["case"], "W_o": w, "historical_L_o": row["L_o"], "L_o": 436*w, "L_o_increase": 14*w, "warning_B": 3*w + 6*436*w, "warning_E": 3*w + 2*436*w})
    dump("warning-refinement.json", {"scope": "R69 all-prefix alias-robust amendment; R68 files retained as scoped history", "filename_upper": 180, "entry_upper": 436, "historical_filename_upper": 166, "historical_entry_upper": 422, "opportunity_counts_unchanged": True, "counter_or_table_persistence_theorem_added": False, "cases": warning_rows})
    result = {"status": "PASS", "checks": checks, "elapsed_seconds": round(time.monotonic() - start, 6), "provider_files": len(inputs), "source_members": len(sources), "strict_source_ranges": sum(len(r["ranges"]) for r in sources), "complete_libraries": len(libraries), "actual_input_cases": len(domains), "predecessor_checker_or_native_runs": 0}
    dump("result.json", result)
    print(json.dumps(result, sort_keys=True))


if __name__ == "__main__":
    try:
        main()
    finally:
        for archive in archives.values():
            archive.close()
