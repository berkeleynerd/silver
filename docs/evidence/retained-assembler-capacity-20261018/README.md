# Retained assembler input and CFI evidence

2026-10-18, Linux x86_64, Refs #119. Supports the
[source derivation](../../research/retained-assembler-capacity.md).

`sources.tar.gz` retains 33 complete files from Binutils release commit
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
buffer/CFI arithmetic. The report supplies the manual reachability argument.
The conditional results are a longest-line buffer transfer, twelve CFI nodes,
a 92-byte local `.eh_frame` contribution and selected symbol-request counts.
They do not establish whole assembler capacity, complete allocator storage,
the generated assembly-input transfer or final relocation reach. Configuration
can independently enable SFrame output; that branch remains explicit.

No compiler, assembler, linker, solver, Lean build, test suite or near-limit
allocation ran for this evidence. Source retrieval, hashing and arithmetic
checks were the only new execution.
