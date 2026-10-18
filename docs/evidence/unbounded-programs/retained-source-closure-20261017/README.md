# Retained source-range closure evidence

Collected on Linux x86_64, 2026-10-17, for
[the source-range supplement](../../../research/retained-source-closure.md)
and [#119](https://github.com/berkeleynerd/silver/issues/119).
This is source inspection, byte reconciliation and retained-trace accounting.
It ran no compiler, GNATprove, Lean build or admission probe.
The 2026-10-18 follow-up adds source hashes, target properties and runtime-entity
mappings for the manual grammar/helper inclusion in the fixed-support report;
it uses the same retained runtime and binder inputs.

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
encoding. `MANIFEST.json` separately binds the evidence files recursively in
this directory (excluding itself and Python bytecode caches).

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

## Driver snapshots and generation rules

`reconcile-driver.py` adds source-only reconciliation of the surviving
`GPR.293256` and `GPR.293263` configuration/name-map/object-path files with
their exact command records. It also retains the current `program-Z0j19G`
project, native ALI, binder source/ALI and producer phase-switch artifacts.
Its output is `driver-reconciliation.json`; copied raw inputs are in
`driver-snapshots/`. The two older runs were stopped exploratory probes, not
successful confirmation evidence. Four older library sources differ from
today's sources; the JSON records this explicitly. All six library sources
in `program-Z0j19G` match the current installation source bytes.

The generator inspection uses GPRbuild `v26.0.0`, peeled commit
`bdfb879cf03643ec8e48a09ce07b08c4a6ff0263`. The archive URL and hash, and the
hashes of both cited source files, are in the reconciliation. It was retrieved
from GitHub's codeload endpoint into `/tmp/silver-retained-gpr-source-20261017/`
and unpacked without building. Version correspondence does not establish the
source identity of the installed GPR executables. No inherited environment
snapshot was found; the supplement states the remaining effective-search
premise rather than assuming that all frontend environment variables were
cleared by the Alire wrapper.

To reproduce into fresh scratch paths, retaining the exact original inputs:

```sh
python3 docs/evidence/unbounded-programs/retained-source-closure-20261017/reconcile-driver.py \
  --installation /home/canto/src/github.com/berkeleynerd/silver \
  --gpr-source /tmp/silver-retained-gpr-source-20261017/gprbuild-bdfb879cf03643ec8e48a09ce07b08c4a6ff0263 \
  --gcc /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --output /tmp/retained-driver-snapshots-recheck \
  > /tmp/retained-driver-reconciliation-recheck.json
cmp docs/evidence/unbounded-programs/retained-source-closure-20261017/driver-reconciliation.json \
  /tmp/retained-driver-reconciliation-recheck.json
diff -r docs/evidence/unbounded-programs/retained-source-closure-20261017/driver-snapshots \
  /tmp/retained-driver-snapshots-recheck
```

The reconciler preserves source files and snapshots verbatim. Names are parsed
as LF-delimited triples; mapped runtime names/bytes must agree with the
installed native directory. It verifies distinct basename requests in these
snapshots, not a universal property of all possible tool invocations. The
one-block configuration transfer and zero additional-alias transfer are
source-derived **conditional** results, with premises in the supplement.

Follow-up checks: the reconciliation JSON and copied inputs regenerated
byte-identically; retained-input hashes and local Markdown links matched.
`git diff --check` passed for the authored files. Raw tool snapshots preserve
their original trailing spaces and final blank lines, so an unfiltered
whitespace check reports those original artifact bytes; they were not edited
to satisfy a formatting check. No compiler, proof, or admission run was added.

## Fixed support and binder source closure

`close-fixed-support.py` records the explicit runtime helper seeds and their
42-specification dependency closure, eight generic instances, relevant
inline/contract occurrences, the Image generic body hash and the binder's
nine-specification frontend closure. It also closes the retained native ALIs
and selected helper variants under `W`/`Y`/`Z` dependency records, giving 98
ALI files and 169 unit entries. Bare generic `W` records have no dependency
filename and are skipped. Every selected specification and ALI is hashed.

The [fixed-support report](../../../research/retained-fixed-support.md)
derives the conditional virtual-source contribution and the binder source
transfer. The collector records lexical writer sites and evaluates the
manually reviewed coefficients; it does not infer a verified control-flow
bound from those sites. The follow-up grammar/helper mapping hashes the
language and six Silver source files, records selected target properties and
runtime-entity mappings, and pins the cited scalar, String, control, cleanup
and GNATprove frontend sources. Reachability and branch exclusions are the
report's manual argument, not a result of lexical matching. Controlled
invocation/search paths, the existing source/tool identity qualifications and
integration with the other capacity representations remain explicit obligations.

```sh
python3 docs/evidence/unbounded-programs/retained-source-closure-20261017/close-fixed-support.py \
  --installation /home/canto/src/github.com/berkeleynerd/silver \
  --gcc /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --gpr-source /tmp/silver-retained-gpr-source-20261017/gprbuild-bdfb879cf03643ec8e48a09ce07b08c4a6ff0263 \
  > /tmp/retained-fixed-support-recheck.json
cmp docs/evidence/unbounded-programs/retained-source-closure-20261017/fixed-support-closure.json \
  /tmp/retained-fixed-support-recheck.json
```

Verification: regenerate and byte-compare the output, independently recalculate
the aligned specification sum and binder transfer, verify recursive manifest
hashes and local Markdown links, and check authored whitespace. No compiler,
proof, admission or toolchain-changing action is part of this collection.
