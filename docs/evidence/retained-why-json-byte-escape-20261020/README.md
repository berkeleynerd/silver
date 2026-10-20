# Fixed JSON byte-escape capacity packet

This new packet covers `Json_base.char/string` and exactly
`Int_x / Lit_padding (Zeros,4) / No_precision` on byte values 0..255.
See the [research argument](../../research/retained-why-json-byte-escape.md).

`check.py` binds the retained source archives, installed executable and existing
disassembly; extracts selected source/native witnesses; checks all 256 native
byte dispatches, the static format AST, stack/layout sites and scoped arithmetic.
It reads earlier results as immutable inputs and does not replay their checkers.
It is an evidence checker, not a semantic or binary-refinement proof.

Run from the repository:

```sh
python3 docs/evidence/retained-why-json-byte-escape-20261020/check.py
```

The script writes generated JSON only inside this new packet. It never executes
the target, captures a process, runs a disassembler or solver, fetches source,
or changes production/admission. `source-witnesses.json`, `native-bodies.json`,
`native-frames.json`, `native-control.json`, `byte-cases.json` and `result.json`
retain the new evidence. `inputs.json` records exact consumed identities;
`round.json` records the selected author setting and actual check timing.

Conditional exports require the stated source/native, numeric-service and
ownership/callback relations. Actual joined bounds remain null. Global formatter
freshness, caller occurrence counts, arbitrary JSON/format programs, complete
save/exit/pipeline capacity and physical sufficiency are not established.
