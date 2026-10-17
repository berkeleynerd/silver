"""Reconcile retained traces with pinned-source arithmetic; run no compiler.

From the repository root:
python3 docs/evidence/unbounded-programs/feasibility-20261017/continuation/planning/reconcile_source_positions.py > docs/evidence/unbounded-programs/feasibility-20261017/continuation/planning/source-position-reconciliation.json
"""

import hashlib
import json
from pathlib import Path
import re
import tarfile


def sha256(data):
    return hashlib.sha256(data).hexdigest()


root = Path(__file__).resolve().parents[6]
base = root / "docs/evidence/unbounded-programs/feasibility-20261017"
archive = base / "source-capacity/source-snapshots.tar.gz"
manifest_path = base / "source-capacity/source-manifest.json"
manifest = json.loads(manifest_path.read_text())
sources = {entry["path"]: entry for entry in manifest["sources"]}
source_rows = []
with tarfile.open(archive) as bundle:
    for name, lines in {
        "types.ads": ["53-56", "190-200", "266"],
        "osint.adb": ["2709-2720"],
        "sinput-l.adb": ["231-239", "377-381", "414-418", "680-703"],
        "sinput.adb": ["851-864"],
        "sinput.ads": ["365-390"],
    }.items():
        data = bundle.extractfile("upstream/" + name).read()
        digest = sha256(data)
        assert digest == sources[name]["sha256"], name
        source_rows.append({"path": name, "sha256": digest, "lines": lines})

probes = []
for name in (
    "null", "static", "mixed", "mixed_expanded", "sparse64k", "dense64k", "blank64k"
):
    path = base / "source-capacity/probes" / name / "stdout.txt"
    data = path.read_bytes()
    pairs = []
    lo = None
    for line in data.decode().splitlines():
        start = re.fullmatch(r"  (?:new )?lo = ([0-9]+)", line)
        end = re.fullmatch(r"  (?:new )?hi = ([0-9]+)", line)
        if start:
            assert lo is None, (name, line)
            lo = int(start.group(1))
        if end:
            assert lo is not None, (name, line)
            pairs.append((lo, int(end.group(1))))
            lo = None
    assert pairs and lo is None, name
    for index, (lo, hi) in enumerate(pairs):
        expected = 0 if index == 0 else ((pairs[index - 1][1] + 4096) // 4096) * 4096
        assert lo == expected and hi >= lo, (name, index, lo, hi, expected)
    extents = [hi - lo for lo, hi in pairs]
    reconstructed = sum(((d + 4096) // 4096) * 4096 for d in extents[:-1]) + extents[-1]
    assert reconstructed == pairs[-1][1], name
    probes.append({
        "probe": name,
        "trace": str(path.relative_to(root)),
        "trace_sha256": sha256(data),
        "source_ranges": len(pairs),
        "sum_extent_excluding_EOF": sum(extents),
        "alignment_plus_EOF_overhead": pairs[-1][1] - sum(extents),
        "final_position": pairs[-1][1],
        "every_recorded_transition_matches": True,
        "closed_form_matches": True,
    })

result = {
    "schema_version": 1,
    "date": "2026-10-17",
    "scope": "Read-only reconciliation of retained macOS traces and frozen GCC source; no compiler, test, proof or native probe was run.",
    "handoff_commit": "df4af4588612f8f0b605570a7dd07e5b0c366b2c",
    "source_commit": manifest["upstream_commit"],
    "script": str(Path(__file__).resolve().relative_to(root)),
    "script_sha256": sha256(Path(__file__).read_bytes()),
    "source_archive": str(archive.relative_to(root)),
    "source_archive_sha256": sha256(archive.read_bytes()),
    "source_manifest": str(manifest_path.relative_to(root)),
    "source_manifest_sha256": sha256(manifest_path.read_bytes()),
    "verified_source_files": source_rows,
    "arithmetic": {
        "alignment": 4096,
        "extent": "Hi-Lo: physical source bytes, or copied template extent for a virtual source",
        "first_Lo": 0,
        "next_Lo": "4096 * floor((previous_Hi + 4096) / 4096)",
        "next_Hi": "next_Lo + extent",
        "closed_form_final_Hi": "sum(4096 * ceil((extent_i + 1) / 4096), i < n) + extent_n",
        "overhead_per_nonfinal_range": "1 through 4096 positions, including EOF and alignment",
        "sufficient_final_Hi_max": 2147479551,
        "headroom_reason": "Keeps next-source Hi+4096 alignment arithmetic and the last Set_Source_File_Index_Table SP+=4096 representable. This is a source-derived sufficient condition, not a measured native failure point.",
        "virtual_source_memory": "Instantiation entries share the template text buffer while reserving distinct aligned source-position ranges.",
    },
    "probes": probes,
    "remaining_obligations": [
        "Bound all phase-dependent physical and virtual source extents and counts under actual build options; a semantic-only trace does not establish expanded-build closure.",
        "Account for preprocessed source replacement and loaded runtime/library units; distinguish physical-name deduplication from repeated virtual template entries.",
        "Close independent line, node/slot, name, list, String, Uint/Udigits and table growth/lock budgets before claiming a universal source rule.",
        "Compare a sound source-sensitive rule with a uniform worst-case envelope; the recurrence alone establishes neither complete soundness nor best tractability.",
    ],
    "not_claimed": [
        "New native observations", "Whole-frontend capacity proof", "An adopted membership rule",
        "No tractable source-sensitive rule exists", "Binary/source attestation",
    ],
}
print(json.dumps(result, indent=2))
