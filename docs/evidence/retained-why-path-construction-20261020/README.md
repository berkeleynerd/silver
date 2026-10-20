# Restored path construction evidence

See the [source/native argument](../../research/retained-why-path-construction.md).
Given a finite immutable input path with dot-joined length <=R, this packet
bounds all selected concat arithmetic, requested destination extents and partial
copy/traversal work. It preserves unknown actual path inputs and leaves complete
allocator/pending callback/restore-table/save/pipeline capacities open.

`source-witnesses.json` and `native-bodies.json` retain exact source and selected
instruction witnesses. `inputs.json` binds their identities and accepted inputs;
`transfer.py` supplies conditional arithmetic. `check.py` compares source ranges
and installed ELF bytes, checks small adverse length combinations and interface
boundaries, and reproduces `result.json`. It executes no native target.

```sh
python3 -B docs/evidence/retained-why-path-construction-20261020/check.py
```

No native process/capture/disassembler, source fetch, solver/proof or predecessor
checker replay occurs. Source reasoning and independent review are still
necessary; the finite checks are not the universal proof.
