# Selected save accumulator evidence

Round 33, 2026-10-20, #119 / #153. The
[source/native argument](../../research/retained-why-save-format-accumulator.md)
bounds fixed typed-format accumulators, synchronous callback nesting, selected
native allocation subtotals and annotation parsing. It does not establish
whole-formatter allocation, the whole native stack or failed-service capacity.

- `template-census.json`: all 29 selected static format sites and their nodes.
- `source-witnesses.json`: exact retained OCaml/Why source excerpts.
- `native-bodies.json`, `native-witnesses.json`: retained disassembly projection,
  reconciled byte-for-byte with the installed retained ELF; no new disassembly.
- `transfer.py`: explicit-premise construction/evaluation/storage interface.
- `result.json`: five occurrence applications, both without service assertions
  and under the named existing relation. Complete-capacity flags remain false.
- `inputs.json`: input identities; `round.json`: settings, checks and timing.

From the repository root:

```sh
python3 -B docs/evidence/retained-why-save-format-accumulator-20261020/check.py
```

`--write` regenerates the four source/census/application JSON records.
`--freeze-native` projects the named functions from the already retained
disassembly text; it never invokes a disassembler or the target. The default
checker needs the frozen projection and hash-identical executable, not the
historical temporary disassembly file. No predecessor checker is replayed.
