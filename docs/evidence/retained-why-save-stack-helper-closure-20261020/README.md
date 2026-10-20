# Round 37 retained save-stack helper closures

See [the research note](../../research/retained-why-save-stack-helper-closure.md).

* `check.py`: focused retained source/native/closure/input and arithmetic join.
* `inputs.json`, `source-witnesses.json`: exact imported identities and sources.
* `native-bodies.json`, `native-frames.json`: retained ELF-checked instructions
  and own frames, including source-selected trap and tail-loop facts.
* `call-closures.json`: complete direct/indirect coverage for the three Task
  roots and two explanation-helper roots, to explicit runtime services.
* `multiplicities.json`: native frame counts used by each component formula.
* `dispatch.json`: selected 816-byte dispatch shell and 4,104-byte bridge probe.
* `result.json`: five-case bounds and explicit unknown whole-save result.
* `round.json`: authorization, selected settings and validation record.

Reproduce with
`python3 docs/evidence/retained-why-save-stack-helper-closure-20261020/check.py`.
It reads the already retained disassembly and installed ELF at their recorded
absolute paths; it executes neither gnatwhy3 nor any predecessor checker and
does not create new disassembly. Native platform: Linux x86-64.

The source-selected closure targets, immutable-container input transfer and
simultaneous multiplicity arguments require review; the checker does not prove
their semantics merely by comparing bytes. Complete save stack, service demand,
ambient preparation stack and physical capacity remain unset. Refs #119, #153.
