# Retained source-range closure evidence

Collected on Linux x86_64, 2026-10-17, for
[the source-range supplement](../../../research/retained-source-closure.md)
and [#119](https://github.com/berkeleynerd/silver/issues/119).
This is source inspection, byte reconciliation and retained-trace accounting.
It ran no compiler, GNATprove, Lean build or admission probe.

`collect.py` writes `source-inventory.json` to stdout. From the repository root:

```sh
python3 docs/evidence/unbounded-programs/retained-source-closure-20261017/collect.py \
  --repo . \
  --gcc /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --spark /tmp/silver-frontend-representation-20261017/availability/spark-source \
  --native-runtime /home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/lib/gcc/x86_64-pc-linux-gnu/16.1.0/adainclude \
  --producer-runtime /home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/lib/gcc/x86_64-pc-linux-gnu/16.1.0/adainclude \
  > /tmp/retained-source-inventory-recheck.json
cmp docs/evidence/unbounded-programs/retained-source-closure-20261017/source-inventory.json \
  /tmp/retained-source-inventory-recheck.json
```

The paths identify retained inputs, not portable installation requirements.
Equivalent directories may be supplied, preserving their contents. GCC is the
complete Ada tree for commit `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`;
its scanned files are checked against the prior complete-source manifest.
SPARK is inspected commit `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`,
whose exact correspondence to the installed producer archive remains unresolved.
The [previous research](../../../research/frontend-representation-result.md)
records retrieval and source/tool qualifications.

Each file digest uses raw bytes. Git blob SHA-1 includes the usual
`blob <decimal-byte-length>\0` prefix. Aggregate manifest SHA-256 hashes a JSON
list in sorted relative-path order. Each entry is
`{"path": relative_posix_path, "bytes": length, "sha256": digest,
"git_blob_sha1": blob_digest}`; serialize with Python `json.dumps`,
`sort_keys=True`, `separators=(",", ":")`, then UTF-8 encode with no appended
newline. The collector's explicit implementation is authoritative for this
encoding. `MANIFEST.json` separately binds the three evidence files in this
directory (excluding itself).

The inventories mask Ada comments and quoted literals before lexical matching,
preserving LF characters for source coordinates. All recorded occurrences are
textual occurrences, including routine definitions/declarations. They are not
a mechanically verified call graph. The supplement manually interprets the
callers and exclusions.

Verification performed: regenerate the JSON and compare bytes; reconcile every
scanned GCC Ada file with the prior baseline manifest; compare all installed
runtime names/bytes; independently recalculate the two aligned fixed-file sums;
check Markdown links and `git diff --check`. No whole-language capacity result
is asserted by any of these checks.
