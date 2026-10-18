# ELF unwind sizing evidence

Source-only Linux LP64 transfer for research #119. See the
[derivation](../../research/retained-linker-eh-frame.md) for premises, caller
obligations and exclusions. `sources.json` records the immutable Binutils
snapshot, file identities and deterministic source archive. This does not
claim that the snapshot is the historical installed build revision.

`check.py` verifies the retained source bytes, selected declarations and
arithmetic. It is a reconciliation aid, not a proof that all callers satisfy
the derivation. No compiler, linker or prover executes:

```sh
python3 docs/evidence/retained-linker-eh-frame-20261018/check.py --output /tmp/eh-check.json
```

`check-results.json` records the result. Input-family composition, encoded
field validity and final relocation reach remain explicit obligations.
