#!/usr/bin/env python3
"""Offline identities/arithmetic for the handwritten individual-obstack transfer."""
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
manifest = json.loads((HERE / "source-manifest.json").read_text())
names = {"include/obstack.h", "libiberty/obstack.c", "gcc/coretypes.h",
         "gcc/memory-block.h", "gcc/memory-block.cc"}
sources = {}
for row in manifest["files"]:
    if row["path"] in names:
        with tarfile.open(HERE / row.get("archive", "new-sources.tar.gz")) as archive:
            data = archive.extractfile(row["path"]).read()
        assert len(data) == row["bytes"]
        assert hashlib.sha256(data).hexdigest() == row["sha256"]
        sources[row["path"]] = data.decode()
assert set(sources) == names
header, impl = sources["include/obstack.h"], sources["libiberty/obstack.c"]
assert "# define _OBSTACK_INTERFACE_VERSION 2" in header
assert "# define _OBSTACK_SIZE_T size_t" in header
for expression in ("size_t sum1 = obj_size + length;",
                   "size_t sum2 = sum1 + h->alignment_mask;",
                   "size_t new_size = sum2 + (obj_size >> 3) + 100;",
                   "if (new_size < h->chunk_size)",
                   "nbytes += lp->limit - (char *) lp;"):
    assert expression in impl
assert "if (size == memory_block_pool::block_size)" in sources["gcc/memory-block.cc"]
assert "static const size_t block_size = 64 * 1024;" in sources["gcc/memory-block.h"]

LIMIT = 2**63 - 1

def chunk(s, c=4064, m=15):
    assert c >= max(24, 16+m) and m >= 0 and (m+1) & m == 0
    return max(c, s+m+s//8+100)

# Monotonic integer arithmetic gives one boundary for this *object* interface.
low, high = 0, LIMIT
while low < high:
    mid = (low+high+1)//2
    if chunk(mid)+15 <= LIMIT:
        low = mid
    else:
        high = mid-1
assert chunk(low)+15 <= LIMIT < chunk(low+1)+15
for s in (0, 1, 40, 20221, 2**31-1, low):
    k = chunk(s)
    assert k+15 <= LIMIT
    for b in (0, s//2, s):
        l = s-b
        requested = max(4064, b+l+15+b//8+100)
        assert requested <= k and requested >= 16+15+b+l
assert chunk(20221) == 22863
result = {
    "source_files_checked": len(sources), "interface_version": 2,
    "default_preferred_chunk": 4064, "default_alignment_mask": 15,
    "header_payload_offset": 16,
    "individual_default_object_sufficient_ceiling": low,
    "driver_string_object_bytes": 20221,
    "driver_chunk_request_bytes": chunk(20221),
    "driver_relative_alignment_ceiling": chunk(20221)+15,
    "aggregate_memory_or_address_gate": False,
    "caller_object_sizes_and_ABI_premise_required": True,
    "compiler_or_proof_executed": False,
}
expected = HERE / "obstack-checks.json"
if expected.exists():
    assert json.loads(expected.read_text()) == result
print(json.dumps(result, indent=2))
