# Bounded exceptional-unwind evidence

Read the [exception prefix note](../../research/retained-why-session-exception-prefix.md).
This separate #119 packet follows frozen formatter repair
`72096d190945da9e9697627b81e3631387574b8a`. It does not close exceptional `R`.

- `source-excerpts.json`: 40 exact excerpts from already retained matching
  Why/OCaml sources, with whole-file identities.
- `why-printer-inventory.json`: all 55 lexical Why registration snippets,
  conservatively including tools/plugins and trailing comments. The extraction
  is lexical; its input is not an OCaml syntax tree.
- `registration-inventory.json`: OCaml/Why printer-registration, converter and
  exception-alias lexical matches, including unlinked upstream tests/tools.
- `native-bodies.json`: 22 bodies / 5,619 bytes extracted from previous
  disassembly and matched to the exact installed executable, plus the static
  closure word linking Sexplib0's registration to its callback.
- `native-census.json`: 26 raw E8/E9 candidates to selected registry/query
  functions, and matching aligned data words. This is diagnostic coverage,
  not indirect-call completeness.
- `inputs.json`, `result.json`, `round.json`: dependencies, selected settings,
  bounded results and available timings. Both exception charge and complete
  `R` are null. Source arguments remain prose obligations.

```sh
python3 docs/evidence/retained-why-session-exception-prefix-20261019/check.py
```

The check is read-only and offline. It does not run a target, debugger,
disassembler, compiler or solver; no capture, replay or broad suite was rerun.
Root owns the aggregate #119 bookkeeping and publication.
