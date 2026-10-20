# Retained private-printer control

See the [research note](../../research/retained-why-save-printer-control.md).
This packet closes the selected printer interrupted-mutation/control residual
without changing the frozen shape/allocation or stack packets.

- `transfer.py`, `result.json`: conditional finite table/candidate traversal bounds.
- `source-witnesses.json`: exact source ranges and whole-member identities.
- `shape-exception-origins.json`: all four ShapeTooLong references in the retained
  Why3 ML/interface archive, including its sole raiser and both shape catches.
- `native-bodies.json`, `native-witnesses.json`, `native-control-facts.json`:
  retained native subset, installed-ELF match and inspected branch/trap sites.
- `inputs.json`: exact hashes of reused evidence.
- `check.py`, `check-result.json`, `round.json`: focused verification and record.

Reproduce with:

```sh
python3 docs/evidence/retained-why-save-printer-control-20261020/check.py
```

The checker reads retained sources, frozen native witnesses and the installed
Linux x86-64 ELF. It does not execute the target, create new disassembly or run
predecessor checkers. Its checks do not mechanically prove the source induction.

No physical resource, runtime service progress or complete save/pipeline result
is asserted. Refs #119, #153.
