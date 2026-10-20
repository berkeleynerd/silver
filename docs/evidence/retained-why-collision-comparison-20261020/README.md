# First-inline collision comparison interface

This packet supports [the source argument](../../research/retained-why-collision-comparison.md)
for #119/#153: old-left/candidate-right equality, zero Ident/hash-tag effects,
and candidate-controlled private arithmetic with finite valid old structures.

Run the focused offline check from the repository root:

```sh
python3 -B docs/evidence/retained-why-collision-comparison-20261020/check.py
```

`inputs.json` pins existing retained bytes. `source-witnesses.json` retains the
new bounded source selections. `native-witness.json` retains the complete
installed `ml_z_compare` body, read statically and checked against ELF bytes.
`compose.py` supplies the pure conditional arithmetic interface; its numeric
inputs are not certificates for arbitrary OCaml values. `result.json` records
its current original-context instantiation. `check-result.json` and `round.json`
record the author check and scope.

No predecessor checker, target, capture, solver or compiler is executed.
Source/operational correctness remains a reviewed argument. Old operand
representation and caller/table conditions are explicit; aggregate old work,
time, RAM and allocator internals are not new completion gates.
