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
