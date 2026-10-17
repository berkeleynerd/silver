# Deferred frontend String storage research evidence

This bundle supports the [candidate design](../../../research/frontend-deferred-storage-feasibility.md)
for research #113. It contains source inspection and exact design arithmetic,
not an implemented rope, compiler build, giant allocation experiment or proof
of automatic discharge. No compiler, runtime, proof implementation or pin changed.

The input GCC commit is `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`; its Ada tree is
`a3b9f0d4c999c8c127cebdc239ca8218284137aa`. The complete Ada source inventory,
retrieval information and prior lifetime result are retained in
[the preceding bundle](../continuation-20261017/frontend-lifetimes/MANIFEST.json).
`audit.py` rechecked all 2,490 blobs (62,760,971 bytes) against that tree with zero
mismatches. These source identities do not attest the installed compiler binary.

| File | Meaning |
| --- | --- |
| `audit.py` | Reproducible source hash checks, lexical inventory, excerpts and exact symbolic arithmetic. It does not compile or execute Ada. |
| `verified-tree-and-inventory.json` | Full-tree verification and inventory counts. |
| `consumer-inventory.json` | 501 matching lines across 53 files, plus 92 package/pointer-reference lines. Comments and literals are filtered; definitions, internal calls and unrelated names remain. |
| `overloaded-consumer-candidates.json` | 208 candidate lines for `Append`/`To_String` in Stringt and Ada units importing it. Most are other overloads. |
| `resolved-routes.json` | Manual classification and the specific semantic/conversion/ABI routes supporting the report. It does not claim complete call resolution. |
| `selected-source-ranges.json`, `selected-source-manifest.json`, `selected-source-excerpts.txt` | Exact line ranges, complete-file hashes and line-numbered excerpts; display trailing whitespace is removed. |
| `gcc-emission-source-manifest.json`, `gcc-emission-sources.tar.gz` | Four additional complete exact-pin GCC files, URL/retrieval/hash metadata and retained compressed bytes. |
| `design-arithmetic.json` | Current witness lower bound and hypothetical DAG node counts, explicitly not measured implementation performance. |
| `identity.json`, `validation.json`, `MANIFEST.json` | Actual research host/base, local verification and bundle hashes. |

Source line numbers count LF separators, matching `nl` and ordinary compiler
diagnostics. GCC's form-feed page separators do not advance the line number.

The initial lexical inventories are preserved in scratch. The reproducible audit
retains the same 501 symbol-matching lines but also includes Stringt's own
overloaded declarations/internal calls and additional direct address-name
references, yielding the final 208/92 candidate counts. None is an operational
call count. Eleven `String_Length` lines belong to unrelated runtime packages;
79 lines are in Stringt's body/specification and four in its C header.

To reproduce, obtain the exact Ada subtree and `ada-tree.json` using the previous
bundle's retrieval record. Extract `gcc-emission-sources.tar.gz` into a new scratch
directory; its four filenames are flattened (`gcc__tree.cc`, etc.). Then run:

```sh
python3 audit.py /path/to/upstream-gcc /path/to/new-output /path/to/extracted-gcc-files
```

The input directory contains `gcc/ada/` and `ada-tree.json`. The script reads
`selected-source-ranges.json` and the GCC manifest alongside itself. Compare the
six generated JSON/text files with the retained versions; they reproduce
byte-for-byte. `resolved-routes.json` is manual review, and the source download
timestamps/archive container are historical evidence rather than regenerated
analysis. The bundle manifest hashes every other retained file.

Research ran in a separate worktree on Linux x86_64 `codex-silver`.
Scratch remains at `/tmp/silver-frontend-deferred-20261017/`; the full Ada source
remains under `/tmp/silver-unbounded-continuation-20261017/upstream-gcc/`.
The raw four additional GCC files were copied to scratch before packaging their
complete contents in the archive. Existing worktrees, installations, caches,
previous evidence and other-host artifacts were preserved. No GNATprove, Lean,
build/bootstrap, full suite or application execution occurred in this lane.
