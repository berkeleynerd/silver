# x86 dynamic-section sizing evidence

Supports the [conditional source transfer](../../research/retained-linker-dynamic-sections.md)
for #119, Linux x86_64, 2026-10-18. Six complete Binutils files are retained
at commit `5e56594815854de5eca35c7c04b11705d0f19c02`, with immutable URLs,
byte counts and hashes in `sources.json`. Previously retained source bytes
are reused where available. This is not a historical binary-build attestation.

```sh
python3 docs/evidence/retained-linker-dynamic-sections-20261018/check.py \
  --output /tmp/link-dynamic-sections.json
```

The checker verifies source identity, selected anchors and the local arithmetic.
The report gives the manual path argument. Its event inputs and complete
layout join remain open. In particular, ELF64 output fields do not widen
the unsigned32 `reloc_count * got_entry_size` intermediate. No compiler,
assembler, linker, prover or large allocation was run for this derivation.
