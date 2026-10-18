# Producer GPR invocation descriptor

Research #119, 2026-10-18. See the
[derivation](../../research/retained-producer-gpr-descriptor.md).

`identity.json` pins selected GCC/SPARK sources, the previously fetched
GPRbuild v26.0.0 archive, and installed XML/entity configuration bytes. The
native and producer database copies were compared read-only and are identical.
Source selection is not installed-executable/source attestation.

Run from the repository root:

```bash
python3 docs/evidence/retained-producer-gpr-descriptor-20261018/check.py
```

The checker parses all63 base XML files and their pinned local entities,
selects the native/default GNAT16.1 branches, reconstructs the244-byte naming
input, exports argument/A-row descriptors and evaluates the generic ALI join.
`naming.reconstructed.adc` is reconstructed text, not a new runtime capture.
`result.json` keeps the remaining orchestration/source-identity limitations
explicit. No compiler, proof, native probe, GPR invocation or installation
was executed. Current source admission is unchanged.
