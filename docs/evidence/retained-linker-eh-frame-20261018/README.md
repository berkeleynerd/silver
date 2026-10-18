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

`fixed-eh-inputs.json` and `fixed-eh-sections.tar.gz` retain the888 nonempty
fixed ET_REL unwind sections, with original file/member identities and the
earlier link-inventory digest. `check-fixed-inputs.py` independently reads
their ELF unwind headers and checks the relevant field extents, entry counts
and weighted sums. Its `--installed` mode also rereads each original file,
verifies the complete file/member hash and repeats section extraction.
This mode executed successfully; it launches no native tool. Ordinary replay
uses only the retained bytes:

```sh
python3 docs/evidence/retained-linker-eh-frame-20261018/check-fixed-inputs.py --output /tmp/fixed-eh-check.json
```

The parser checks selected headers/encoded lengths. It does not interpret
CFA instruction semantics, prove relocation validity or include generated
Main/binder/linker-created unwind sections. The installed check's result is
`fixed-input-check-results.json`; its field widths and payload contribution
are narrower claims than whole-link capacity.
