#!/usr/bin/env python3
"""Check retained Common-pool metadata domains without executing native tools."""

import argparse
import hashlib
import json
from pathlib import Path
import tarfile

from auxiliary_domains import check


ROOT = Path(__file__).resolve().parent
CASES = ("put", "put_line", "first_or_default", "input_is_valid", "reject")
LIST_LABELS = {
    "proper_proof_in", "proper_input", "proper_output",
    "refined_proof_in", "refined_input", "refined_output",
    "initializes", "refined_initializes", "local_var",
    "ENTRY_CALLS", "SUSPENDS_ON", "UNSYNCH_ACCESSES",
}


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def rows(raw):
    return [s.split() for s in raw.decode().splitlines() if s.startswith("GG ")]


def metadata():
    retained = ROOT / "intern-counters"
    manifest = json.loads((retained / "manifest.json").read_text())
    archive = retained / manifest["archive"]
    assert digest(archive.read_bytes()) == manifest["sha256"]
    files = {}
    with tarfile.open(archive) as tar:
        for member in tar:
            if not member.isfile():
                continue
            raw = tar.extractfile(member).read()
            expected = manifest["members"][member.name]
            assert len(raw) == expected["size"]
            assert digest(raw) == expected["sha256"]
            if member.name.startswith("probe/library-obj/") and member.name.endswith(".ali"):
                files[member.name] = raw
            elif member.name in {f"probe/{case}/obj/main.ali" for case in CASES}:
                files[member.name] = raw
    assert len(files) == 9
    callees, globals_, contracts = set(), set(), set()
    token_counts = {}
    max_parents = 0
    for name, raw in sorted(files.items()):
        records = rows(raw)
        # All tokens after GG and entry kind overcount actual name tokens.
        token_counts[name] = sum(len(t) - 2 for t in records)
        if not name.startswith("probe/library-obj/"):
            continue
        for fields in records:
            kind = fields[1]
            if kind == "EK_GLOBALS":
                contracts.add(fields[2])
                if fields[5] in ("E_FUNCTION", "E_PROCEDURE"):
                    callees.add(fields[2])
                assert fields[7] == "ORIGIN_FLOW"
                max_parents = max(max_parents, int(fields[8]))
                for i, token in enumerate(fields):
                    if token in LIST_LABELS:
                        count = int(fields[i + 1])
                        globals_.update(fields[i + 2:i + 2 + count])
                # No package adds a recursive child-package/local-package
                # States_And_Objects traversal in the retained closure.
                if "local_packages" in fields:
                    assert fields[fields.index("local_packages") + 1] == "0"
            elif kind in ("EK_STATE_MAP", "EK_PART_OF"):
                globals_.add(fields[2])
                globals_.update(fields[4:4 + int(fields[3])])
            elif kind == "EK_REMOTE_STATES":
                globals_.update(fields[3:3 + int(fields[2])])
            elif kind in ("EK_DIRECT_CALLS", "EK_PROOF_DEPENDENCIES"):
                callees.update(fields[4:4 + int(fields[3])])
    assert len(callees) == len(globals_) == 12
    assert len(contracts) == 16 and max_parents == 1
    assert sum(token_counts.values()) == 17223
    return {
        "retained_archive_sha256": manifest["sha256"],
        "token_upper_counts": token_counts,
        "fixed_token_allowance": sum(token_counts.values()),
        "fixed_callable_names": sorted(callees),
        "fixed_global_state_names": sorted(globals_),
        "fixed_global_contract_count": len(contracts),
        "maximum_explicit_parent_count": max_parents,
    }


def runtime_inventory(runtime_root):
    entries = []
    total = 0
    for path in sorted(runtime_root.glob("*.ali")):
        raw = path.read_bytes()
        assert not any(line.startswith(b"GG ") for line in raw.splitlines()), path
        entries.append(f"{path.name}\0{digest(raw)}\0{len(raw)}\n")
        total += len(raw)
    assert len(entries) == 880
    return {
        "root": str(runtime_root),
        "files": len(entries),
        "total_bytes": total,
        "gg_records": 0,
        "sorted_name_nul_sha256_nul_size_lf_digest": digest("".join(entries).encode()),
        "scope": "Read-only installed-runtime metadata inspection; no historical build attestation.",
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--source-archive", type=Path, required=True)
    parser.add_argument("--runtime-root", type=Path, required=True)
    args = parser.parse_args()
    source = check(args.source_root, args.source_archive)
    result = metadata()
    c = len(result["fixed_callable_names"])
    g = len(result["fixed_global_state_names"])
    folds = 3 * (result["fixed_global_contract_count"] + 2)
    scope_calls = folds * (6 * c * g + 12 * g)
    main_schema = 6 + 5 * c + 9 * g
    fixed = result["fixed_token_allowance"] + scope_calls + main_schema + 2
    assert folds == 54 and scope_calls == 54432 and main_schema == 174
    assert fixed == 71831
    result.update({
        "spark_source_archive_sha256": source["archive_sha256"],
        "verified_complete_ada_files": source["verified_complete_ada_files"],
        "runtime_inventory": runtime_inventory(args.runtime_root),
        "fold_invocation_bound": folds,
        "scope_intern_call_bound": scope_calls,
        "main_nonconstant_schema_bound": main_schema,
        "constant_record_name_bound_per_main_entity": 1 + c,
        "fixed_common_call_allowance": fixed,
        "ordinary_producer_bound": "71831 + E_total + 13 E_Main",
        "scope": "Source/metadata bound for ordinary producer translation and serialization. "
                 "Failed-proof diagnostic Get_Fix calls are a separate extension.",
        "toolchain_or_proof_processes_run": False,
    })
    (ROOT / "common-metadata-check.json").write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps({key: result[key] for key in (
        "fixed_token_allowance", "fold_invocation_bound", "scope_intern_call_bound",
        "ordinary_producer_bound", "toolchain_or_proof_processes_run")}))
