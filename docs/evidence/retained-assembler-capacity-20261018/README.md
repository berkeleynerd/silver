# Retained assembler input and CFI evidence

2026-10-18, Linux x86_64, Refs #119. Supports the
[source derivation](../../research/retained-assembler-capacity.md).

`sources.tar.gz` retains 45 complete files from Binutils release commit
`5e56594815854de5eca35c7c04b11705d0f19c02`. `source-manifest.json` records
their byte counts, SHA256 identities and immutable retrieval URLs. The checker
also matches the commit against the previously retained linker release-tag
record. This is source identity, not historical binary-build attestation.

Run without an assembler, compiler, linker or prover:

```sh
python3 docs/evidence/retained-assembler-capacity-20261018/check.py \
  --output /tmp/retained-assembler-capacity-check.json
```

The checker reads archive members without extracting or executing them,
checks the exact LF-numbered excerpts, selected branch/source anchors and
buffer/instruction/frame arithmetic. The report supplies the manual reachability
argument. The conditional results are a longest-line buffer transfer, twelve
CFI nodes, 26 bytes of selected instruction encodings, a 92-byte local
`.eh_frame` contribution, at most six SFrame rows and 91 SFrame bytes, an
optional 48-byte x86 property note, and selected symbol-request counts.
The initial fragment join bounds those paths by 540 fragment allocations.
The unit-emission extension then includes compiler property notes, the
identifier, optional 36-byte build note, eleven subsection starts and final
alignment/sentinel events. At the selected 29-byte identifier it bounds payload
by 420 bytes and fragment allocations by 922, with individual 4064-byte
obstack requests and at most ten per-section region increments. The generated
line-length bound fits the initial scrub buffer. These are not ELF file size,
whole assembler capacity, complete allocator storage or final relocation reach.
Configuration can independently enable SFrame/property/build-note output;
all three branches are charged.

No compiler, assembler, linker, solver, Lean build, test suite or near-limit
allocation ran for this evidence. Source retrieval, hashing and arithmetic
checks were the only new execution.
