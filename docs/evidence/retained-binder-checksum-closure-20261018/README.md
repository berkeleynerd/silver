# Reviewed output-binder checksum closure

Source-only research #119, 2026-10-18. The
[readable source argument](../../research/retained-binder-checksum-closure.md)
retains the reviewed derivation verbatim after its integration preface. The
[independent review](review.md) accepted the stated conditional scope without
material findings. No compiler, assembler, linker, prover, Lean, or native
validation rerun was used for this packaging.

For every uint32 Main checksum in the selected fixed output-binder family, the
accepted bounds are 5,167,732 cumulative rounded GGC bytes, 56,378 positive
allocation events, and a 262,144-byte largest rounded request. The total stays
75,148 bytes below the inherited conservative 5 MiB first-collection threshold.
The Ada Uint correction is separate: the baseline's two rows/six digits dominate
the literal, with at most one extra ordinary 16-byte cache wrapper.

Replay from the repository root:

```sh
python3 docs/evidence/retained-binder-checksum-closure-20261018/check.py
```

The checker also accepts its absolute path from another working directory.
The wrapper verifies the archive and pinned
original identities, extracts the complete reviewed directory into a temporary
directory, and runs its unchanged checker there. That original checker writes
`result.json`; the wrapper requires the rewritten bytes and stdout to equal the
frozen archived result and the published result. The retained packet stays
unchanged. Arithmetic replay corroborates the source argument and does not
replace it.

`reviewed-inputs.tar.gz` contains the full frozen candidate, including its
31 source files, complete counter inputs, source-corpus manifests, installed
instruction windows/disassemblies, derivation, original checker and results.
`identity.json` preserves the archive identity and the four original identities
named by the reviewer. `review.md` is an unchanged copy of the review supplied
for this integration. The human-readable derivation copy is checked byte for
byte against the archived derivation during packaging.

Frozen historical text remains intentional: the archived result's status still
says “Source derivation supplied for independent review,” and the derivation's
handoff still says review is pending. Those are the original candidate's state,
not the current verdict. Acceptance is recorded in the linked review and the
integration preface; no reviewed arithmetic, manifest, checker or result was
rewritten to change a status label.

The closure uses the predecessor's fixed source/options/dependency/path
projection and documented relevant-source/installed-behavior, ABI, allocator and
physical-resource assumptions. It does not identify all historical tool build
inputs, establish whole-tool capacity, discharge the Main/link/producer
conjunction, change admission or production options, or provide macOS evidence.
