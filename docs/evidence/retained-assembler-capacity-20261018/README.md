# Retained assembler input and CFI evidence

2026-10-18, Linux x86_64, Refs #119. Supports the
[source derivation](../../research/retained-assembler-capacity.md).

`sources.tar.gz` retains 41 complete files from Binutils release commit
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
The fragment join bounds these selected paths by 540 fragment allocations,
with individual 4064-byte obstack requests and at most two region increments;
it excludes subsection startup, other directives and final padding/sentinels.
They do not establish whole assembler capacity, complete allocator storage,
the generated assembly-input transfer or final relocation reach. Configuration
can independently enable SFrame/property-note output; both branches are charged.

No compiler, assembler, linker, solver, Lean build, test suite or near-limit
allocation ran for this evidence. Source retrieval, hashing and arithmetic
checks were the only new execution.
