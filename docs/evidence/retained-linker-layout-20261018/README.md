# Selected ELF section/header transfer evidence

Supports [retained-linker-layout.md](../../research/retained-linker-layout.md)
for #119. Native target: retained Linux x86-64 tools. Created 2026-10-18 using
source/retained-byte reads and Python only; no native tool was executed.

`sources.tar.gz` contains 27 complete pinned Binutils files.
`sources.json` records their individual identities and capsule hash. The
files were checked against the previously retrieved full source manifest
at commit `5e56594815854de5eca35c7c04b11705d0f19c02`. `inputs.json` pins the
four unchanged prior records used here. `section-families.json` is the
reviewed constructor-family census. `check-results.json` retains the exact
script declaration list and arithmetic interfaces.

Replay into a fresh output path:

```sh
python3 docs/evidence/retained-linker-layout-20261018/check.py --output /tmp/retained-linker-layout-replay.json
```

The checker hashes retained source/input bytes, checks reviewed source
anchors, extracts the installed script's section declarations and ELF64
external header widths, and reconciles fixed/Main count arithmetic. It does
not execute or semantically verify the C code. The handwritten control-flow
argument supplies multiplicities and exclusions. Binder counts remain
symbolic. Final virtual layout, whole-file length, relocation reach,
allocation lifecycle and complete tool capacity remain open.

Independent review replayed 27 source and four prior-input identities with
byte-equal results, then checked the common/dynamic-relocation constructor
guards, synthetic union, script/orphan counts, hidden ELF headers and
actual/preliminary program-header cases. It found no defect in the narrow
`I/S/N/T` transfer or the unsigned header-product conditions. The review made
no whole-file, virtual-layout or relocation-reach claim.

`check-virtual.py` and `virtual-results.json` extend this with the conditional
script placement transfer from symbolic post-edit payload `B` and alignment
`A`. `B` sums per-item upper bounds across passes. The retained endpoint
bound is `V`, while temporary changed-base RELRO passes have the separate
bound `2 V`; the arithmetic condition covers both. They reuse the same
capsule/input identities and check the script alignment inventory plus
reset/RELRO source anchors:

```sh
python3 docs/evidence/retained-linker-layout-20261018/check-virtual.py --output /tmp/retained-linker-virtual-replay.json
```

This extension does not supply concrete generated payload/alignment inputs,
file length, relocation reach or mapping-iteration convergence.

`check-file.py` and `file-results.json` supply a second conditional transfer
from the virtual envelope, effective alignment and the still-symbolic
`Bfile` section/table payload envelope. They cover load-segment placement,
the initial and pending non-load walks, direct symbol-table output, the
section-name table and header suffix. Replay:

```sh
python3 docs/evidence/retained-linker-layout-20261018/check-file.py --output /tmp/retained-linker-file-replay.json
```

Its per-phase multiplicities are a handwritten source argument. Neither
conditional extension completes the generated payload/alignment projection
or claims a concrete whole-program layout bound.

Independent focused review replayed both conditional checkers byte-equal
against all 27 source identities. It checked the RELRO target/revert and
phase reset, per-item payload condition, source alignment/page expressions,
load-segment bias and writer walks. The review required the separate `2 V`
trial bound before accepting the transfer. Payload/alignment projections,
mapping convergence and relocation reach remain open.

`check-fixed-payload.py` re-reads the 15 pinned fixed file spellings and 1,161
archive members, excluding generated objects. It adds original all-section
payload, symbol-size, common-symbol and alignment inputs to the existing
inventory. `fixed-payload-source.json` pins the complete extra x86 ELF header
in `fixed-payload-x86-64.h.gz`; all 27 prior sources and four inputs are
rechecked too. The result retains explicit input multiplicities and the
eight additional loader processings separately:

```sh
python3 docs/evidence/retained-linker-layout-20261018/check-fixed-payload.py --output /tmp/retained-linker-fixed-payload-replay.json
```

This establishes original input quantities, not post-edit payload closure.
No fixed common symbol or alignment above 64 bytes was found. Generated
objects, synthetic growth and final hidden tables remain separate joins.

The checker also retains the fixed merge-entry segmentation and alignment
charges. Its 3,168,199-byte merge-output transfer follows the pinned
`bfd/merge.c` grouping/deduplication/suffix and placement paths. The full
merged allowance is added to original input bytes for per-input maxima
across pre/post merge placement. Generated merge entries and other linker
transformations remain open.

Independent narrow review replayed this extended checker byte-equal against
28 sources, four inputs, 15 fixed files and 1,161 archive members. It checked
entry segmentation/extra zero, effective alignment, group matching,
deduplication's maximum alignment, suffix removal, both output placement
loops and final padding. It accepted the additive merge and original-plus-
merged bounds, including the single merge-before-sizing source join.
Generated group members/alignments and other transformations remain open.

`check-properties.py` adds a complete fixed-note census and the source-derived
property union/rewrite transfer; it rechecks all fixed ELF/member identities.
`check-unwind-join.py` combines fixed and Main evidence with the selected
PLT template arrays. `transformation-inputs.json` pins those three earlier
records; `transformation-source.json` pins the complete additional x86
backend header. Both checkers retain generated binder terms and actual narrow
writer/editing conditions:

```sh
python3 docs/evidence/retained-linker-layout-20261018/check-properties.py --output /tmp/retained-linker-properties-replay.json
python3 docs/evidence/retained-linker-layout-20261018/check-unwind-join.py --output /tmp/retained-linker-unwind-join-replay.json
```

Neither establishes generated DWARF/CFA semantics, relative relocation reach,
SFrame closure or complete linker capacity.

Independent narrow review replayed both outputs byte-equal, including 27/28
source identities and the property census's 15 fixed files/1,161 members.
It checked property union/max-data behavior, all source additions, writer
alignment and unsigned size; PLT template assignment and four-byte FDE
ranges; and the joined EH arithmetic. It accepted these conditional transfers
with the binder, generated semantics and reach premises still open.

`check-section-indices.py` rechecks 29 complete sources, six prior input
identities, 15 fixed file spellings and 1,161 members. It counts original
REL/RELA headers and reconciles the selected no-hidden-relocation-header
source argument. Two additional complete sources are retained in the
`section-index-*.gz` capsules and pinned by `section-index-inputs.json`.

```sh
python3 docs/evidence/retained-linker-layout-20261018/check-section-indices.py --output /tmp/retained-section-indices-replay.json
```

The result preserves the binder condition rather than substituting the
observed binder. The source anchors reconcile the handwritten reachability
argument; they do not execute ld or automatically prove C control flow.

Independent narrow review replayed the result byte-equal and checked the
original relocation-header/target charge, cached synthetic section creation,
all output relocation-count branches, the nonrelocatable constructor-set
guard, output private-data copying, and section-number assignment. It
accepted the conditional dynamic-index transfer; binder substitution and
whole-link capacity remain separate.
