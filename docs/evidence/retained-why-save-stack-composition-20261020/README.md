# Round 36 retained save-stack composition

See [the research note](../../research/retained-why-save-stack-composition.md).

* `check.py`: focused retained-source/frame/input and arithmetic checker.
* `inputs.json`: exact identities of imported packets, raw archives and native evidence.
* `source-witnesses.json`: selected source ranges with whole-member identities.
* `native-bodies.json`, `native-frames.json`: selected retained bodies and frame facts.
* `administrative-inputs.json.gz`: complete new initial binder-map projection,
  variable-only substitution-value witnesses and read-pointer inventory.
* `administrative-summary.json`: compact initial/dynamic transfer interface.
* `result.json`: scoped native frame sums and explicit unknown complete bounds.
* `round.json`: selected settings, authorization and validation record.

Reproduce with `python3 docs/evidence/retained-why-save-stack-composition-20261020/check.py`.
The checker requires the already retained disassembly and installed ELF at the
recorded absolute paths. It reads them; it never executes the target or creates
new disassembly. Predecessor checkers are not invoked. Native platform: Linux
x86-64. The source-level transfer and exact residual are reviewed arguments,
not consequences of identity checks alone.

This packet does not establish complete save stack, physical capacity, service
success, scheduling stack or whole-pipeline assurance. Refs #119, #153.
