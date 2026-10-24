#!/usr/bin/env python3
"""Offline source identity, caller census and incoming-transfer checks.

The source classification in the companion report is manual and reviewable.
These checks do not infer Ada reachability or run an external toolchain.
"""

import hashlib
import json
import re
import tarfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
ARCHIVE = ROOT / (
    "docs/evidence/unbounded-programs/frontend-representation-20261017/"
    "toolchain/raw-evidence.tar.gz"
)
ARCHIVE_SHA = "f2e7dd7bbef086a36ddf97f9bd3bd669ca895fcc28e3ac23ffe0c9f85fc5d952"
GCC_PIN = "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
SPARK_PIN = "42554fc241fcd1fdf08d3a2feccb3f86912acbc0"
LOCAL = [
    "src/silver_io.ads", "src/silver_io.adb", "src/silver_arguments.ads",
    "src/silver_arguments.adb", "src/silver_output_libc.ads", "src/silver_runtime.ads",
]
GCC_FILES = [
    "types.ads", "erroutc.ads", "erroutc.adb", "libgnat/system-linux-x86.ads",
    "libgnat/a-textio.ads", "libgnat/a-comlin.ads", "libgnat/i-c.ads", "inline.adb",
]
FLOW_FILES = [
    "flow/flow-analysis.adb", "flow/flow-analysis-antialiasing.adb",
    "flow/flow-analysis-sanity.adb", "flow/flow-control_flow_graph.adb",
    "flow/flow_classwide.adb", "flow/flow_sanity.adb", "flow/flow.adb",
    "flow/flow_error_messages.adb", "flow/flow_types.adb",
    "utils/errout_wrapper.adb", "common/vc_kinds.adb",
]
CALLER_FILES = FLOW_FILES[:7]
SOURCE_RANGES = {
    "flow/flow_types.ads": [(97, 184), (859, 859)],
    "flow/flow_utility.adb": [(1020, 1106), (1233, 1301)],
    "flow/flow-control_flow_graph.adb": [
        (1242, 1290), (1357, 1395), (1506, 1706), (2009, 2039),
        (2440, 2532), (2591, 2705), (3397, 3454), (3609, 3666),
        (4007, 4118), (4205, 4222), (4306, 4353), (4878, 4902),
        (4993, 5034), (5150, 5208), (6048, 6052), (6102, 6119),
        (6238, 6258), (6278, 6294), (6318, 6339), (6393, 6433),
        (6442, 6539), (6556, 6625), (6688, 6735), (6863, 7087),
        (7186, 7215), (7339, 7385), (7849, 7874), (8441, 8474),
        (8490, 8530), (8742, 8843), (9180, 9258),
    ],
    "flow/flow-analysis.adb": [
        (1831, 1850), (1960, 2058), (2370, 2402), (2550, 2603),
        (2630, 2737), (3107, 3134), (3160, 3228), (3376, 3399),
        (4125, 4138), (4963, 4975),
    ],
    "flow/flow-analysis-antialiasing.adb": [(666, 744), (933, 1197)],
    "flow/flow_error_messages.adb": [
        (192, 253), (303, 499), (501, 608), (1013, 1018),
        (3960, 4116), (4446, 4688), (5013, 5029),
    ],
    "flow/flow.adb": [(1538, 1593), (1655, 1778), (1869, 1918)],
    "flow/flow_generated_globals-phase_2.adb": [
        (2402, 2513), (2536, 2633), (2974, 3015), (4134, 4301), (4535, 4537),
    ],
    "utils/errout_wrapper.adb": [(17, 17), (76, 190), (399, 530), (599, 669), (852, 918)],
    "common/vc_kinds.ads": [(673, 680), (770, 784), (810, 814)],
    "common/vc_kinds.adb": [(167, 235), (1889, 1919), (2205, 2212)],
    "why/gnat2why-driver.adb": [(348, 384), (554, 569), (790, 831), (1121, 1145)],
    "why/gnat2why-expr.adb": [(20258, 20296)],
    "spark/spark_definition.adb": [
        (2313, 2389), (4289, 4308), (6543, 6582), (11834, 11852),
        (12208, 12249), (12873, 12892), (5667, 5683), (8607, 8618),
        (13244, 13259), (14000, 14025),
    ],
    "spark/spark_util.adb": [(1917, 1951), (4817, 4852)],
    "spark/spark_util-subprograms.adb": [(786, 861)],
}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def lex_ada(text):
    """Preserve code positions; replace comments and literals by spaces."""
    out = list(text)
    literals = []
    i = 0
    while i < len(text):
        if text.startswith("--", i):
            end = text.find("\n", i)
            if end < 0:
                end = len(text)
            out[i:end] = " " * (end-i)
            i = end
        elif text[i] == "'" and i+2 < len(text) and text[i+2] == "'":
            literals.append(text[i+1])
            out[i:i+3] = "   "
            i += 3
        elif text[i] == '"':
            start = i
            value = []
            i += 1
            while True:
                assert i < len(text), "unclosed Ada string"
                if text[i] == '"':
                    if text[i:i+2] == '""':
                        value.append('"')
                        i += 2
                    else:
                        i += 1
                        break
                else:
                    value.append(text[i])
                    i += 1
            literals.append("".join(value))
            out[start:i] = " " * (i-start)
        else:
            i += 1
    return "".join(out), literals


def callers(sources, token):
    found = []
    for name, data in sorted(sources.items()):
        if not name.endswith(".adb"):
            continue
        raw = data.decode()
        code, _ = lex_ada(raw)
        for match in re.finditer(r"\b" + token + r"\s*\(", code, re.I):
            before = code[max(0, match.start()-30):match.start()]
            if re.search(r"\b(?:procedure|function)\s*$", before, re.I):
                continue
            found.append({"file": name, "line": raw.count("\n", 0, match.start())+1})
    return found


def graph(a, e, lists):
    """Parameters are established frontend bounds, never measured graph data."""
    assert min(a, e, lists) >= 0
    g = 6
    f = 2*(e+g)+1
    v = 10+4*e+4*g+(16+2*g)*a+lists
    return {
        "A": a, "E": e, "L": lists, "G": g, "F": f, "V": v,
        "flow_attempts": 2*a*f+7*v*f+12*f+v*(4+a)+13*a+e+6,
        "trace_attempts": v+2*v*f,
        "trace_lines_each": v,
        "graph_warning_attempts": a*a+13*a,
    }


def global_closure(direct, calls):
    """Finite powerset model for checking the stated domain induction."""
    sets = {key: set(val) for key, val in direct.items()}
    universe = set().union(*sets.values())
    additions = 0
    while True:
        changed = False
        for caller, callees in calls.items():
            new = set().union(*(sets[callee] for callee in callees)) if callees else set()
            delta = new-sets[caller]
            additions += len(delta)
            sets[caller] |= delta
            assert sets[caller] <= universe
            changed |= bool(delta)
        if not changed:
            return sets, additions


def lifecycle(attempts):
    """Model the ordering, not native Msg_Id initialization bugs or formatting."""
    keys = set()
    traces = 0
    records = 0
    prints = 0
    for msg, sloc, severity, path, suppressed in attempts:
        traces += bool(path)  # FA-overload eager initializer precedes dedup
        key = (msg, sloc, severity)
        if key not in keys:
            keys.add(key)
            records += 1
            prints += not suppressed
    return traces, records, prints


def main():
    assert sha(ARCHIVE.read_bytes()) == ARCHIVE_SHA
    with tarfile.open(ARCHIVE) as archive:
        sources = {
            member.name.removeprefix("spark-source/src/"): archive.extractfile(member).read()
            for member in archive.getmembers()
            if member.isfile() and member.name.startswith("spark-source/src/")
        }
    prior = json.loads((ROOT / (
        "docs/evidence/unbounded-programs/continuation-20261017/"
        "frontend-lifetimes/complete-source-manifest.json"
    )).read_text())
    assert prior["commit"] == GCC_PIN
    expected = {entry["path"]: entry for entry in prior["files"]}
    with tarfile.open(HERE / "gcc-sources.tar.gz") as archive:
        gcc = {name: archive.extractfile(name).read() for name in GCC_FILES}
    for name, data in gcc.items():
        assert sha(data) == expected[name]["sha256"], name
        assert len(data) == expected[name]["bytes"], name
    old_identity = json.loads((HERE / "identity.json").read_text())
    for name in LOCAL:
        assert sha((ROOT / name).read_bytes()) == old_identity["local_sources"][name], name

    inventory = {token: callers(sources, token) for token in (
        "Error_Msg_Flow", "Warning_Msg_N", "Error_Msg_N",
        "Entity_To_Subp_Assumption",
    )}
    inventory["Next_Message_Id"] = []
    for name, data in sorted(sources.items()):
        if not name.endswith(".adb"):
            continue
        raw = data.decode()
        code, _ = lex_ada(raw)
        for match in re.finditer(r"\bNext_Message_Id\b", code):
            if re.search(r"\b(?:function|end)\s*$", code[max(0, match.start()-30):match.start()]):
                continue
            inventory["Next_Message_Id"].append(
                {"file": name, "line": raw.count("\n", 0, match.start())+1})
    assert len(inventory["Entity_To_Subp_Assumption"]) == 9
    assert len(inventory["Next_Message_Id"]) == 1

    constants = {}
    for name in FLOW_FILES:
        _, literals = lex_ada(sources[name].decode())
        constants[name] = {
            "literal_bytes": sum(len(x.encode()) for x in literals),
            "literal_at_characters": sum(x.count("@") for x in literals),
        }
    c = sum(x["literal_bytes"] for x in constants.values())
    a_at = sum(x["literal_at_characters"] for x in constants.values())
    assert (c, a_at) == (52020, 8)
    caller_max = max(constants[name]["literal_bytes"] for name in CALLER_FILES)
    caller_at = max(constants[name]["literal_at_characters"] for name in CALLER_FILES)

    def range_literals(name, lo, hi):
        text = "\n".join(sources[name].decode().splitlines()[lo-1:hi])
        return lex_ada(text)[1]

    wrapper_bytes = sum(map(len, range_literals("flow/flow_error_messages.adb", 303, 499)))
    cwe_id = max(map(len, range_literals("common/vc_kinds.adb", 167, 228)))
    cwe_wrapper = sum(map(len, range_literals("common/vc_kinds.adb", 2205, 2212)))
    flow_c = caller_max + wrapper_bytes + cwe_id + cwe_wrapper
    assert (caller_max, wrapper_bytes, cwe_id, cwe_wrapper, flow_c, caller_at) == (5265, 12, 4, 7, 5288, 2)
    warning_image_template = sum(map(len, range_literals("common/vc_kinds.ads", 810, 814)))
    assert warning_image_template == 168
    # Create_N resolves &: quoted Image has7 characters; suffix [imprecise-image]
    # has18. No apostrophe in this template is doubled by Create_N.
    warning_image = warning_image_template - 1 + 7 + 18
    assert warning_image == 192

    snippets = ["# Incoming source witnesses\n\n",
                "Complete SPARK files remain in the hash-pinned archive; GCC "
                "files in gcc-sources.tar.gz are verified against the earlier "
                "complete-source manifest. These excerpts do not prove reachability.\n"]
    manifest = {}
    for name, ranges in SOURCE_RANGES.items():
        data = sources[name]
        lines = data.decode().splitlines()
        manifest[name] = {"bytes": len(data), "sha256": sha(data), "ranges": ranges}
        for lo, hi in ranges:
            assert 1 <= lo <= hi <= len(lines)
            snippets.append(f"\n## {name}:{lo}–{hi}\n\n```ada\n")
            snippets.extend(f"{i}: {lines[i-1]}".rstrip()+"\n" for i in range(lo, hi+1))
            snippets.append("```\n")

    # Distinguish same entity/location but different text; trace before dedup;
    # suppressed warning still retains its record.
    assert lifecycle([
        ("unused A", 7, 1, {2}, False),
        ("unused A", 7, 1, {2}, False),
        ("unused B", 7, 1, {2}, True),
    ]) == (3, 2, 1)
    direct = {"Main": set(), "Put": {"FS", "Bytes", "Count", "Flushed", "Succeeded"},
              "Reject": {"FS"}, "Query": set(), "Setter": {"Exit"}}
    closure, added = global_closure(direct, {"Main": {"Put", "Reject", "Query"}})
    assert closure["Main"] == direct["Put"]
    assert added <= len(direct)*6
    # No-record compressed leaves: whole array or its bounds replaces/grouped
    # leaves; repeated path variables do not create additional (Start,Use) keys.
    checks = {("start", use): {("x", "normal"), ("x", "bounds"), ("i", "normal")}
              for use in range(5)}
    assert len(checks) == 5
    assert sum(map(len, checks.values())) == 5*3
    # Cut-boundary regression: the separately safe suffix does not make the
    # combined process counter representable.
    last = 2**31-1
    incoming, suffix = last-2, 3
    assert suffix <= last and incoming+suffix > last

    examples = {"null_generic_orientation": graph(39, 1, 39),
                "symbolic_small_orientation": graph(100, 10, 30)}
    assert examples["null_generic_orientation"]["V"] == 1169
    result = {
        "scope": "Offline source census and integer transfer checks; no native/proof run",
        "candidate_source_revision": SPARK_PIN,
        "archive_sha256": ARCHIVE_SHA,
        "gcc_revision": GCC_PIN,
        "callers": inventory,
        "literal_envelope": {
            "all_modules_sum": c, "all_modules_at_count": a_at,
            "flow_message_C": flow_c, "flow_message_at_count": caller_at,
            "flow_caller_module_max": caller_max,
            "flow_wrapper_literals": wrapper_bytes,
            "cwe_id_max": cwe_id, "cwe_wrapper_literals": cwe_wrapper,
            "warning_raw_text_max": warning_image, "files": constants,
        },
        "sources": manifest,
        "orientation_only": examples,
        "native_column_last": 32767,
        "native_message_buffer": 1024+2*32767,
        "not_established_by_script": [
            "Ada reachability and source-domain classification",
            "Installed binary correspondence",
            "An ordinary program's complete #119 predicate membership",
            "Host RAM, stack, disk or external progress",
        ],
    }
    (HERE / "result.json").write_text(json.dumps(result, indent=2, sort_keys=True)+"\n")
    (HERE / "source-excerpts.md").write_text("".join(snippets))
    print(json.dumps({"status": "passed", "flow_message_C": flow_c,
                      "warning_raw_text_max": warning_image,
                      "caller_counts": {k: len(v) for k, v in inventory.items()}}, sort_keys=True))


if __name__ == "__main__":
    main()
