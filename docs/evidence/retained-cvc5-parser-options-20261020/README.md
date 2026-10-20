# CVC5 parser/options offline packet

This packet supports [the research note](../../research/retained-cvc5-parser-options.md)
for #119 / #153, Round 47. It reuses the complete CVC5 archive at revision
`86cecd83b685f59e884094693b9a4c5c90a62e03`; no new source download or executable
run was needed. All paths are repository relative unless an archive member is
explicitly identified.

- `inputs.json` identifies the exact reused archives and accepted documents.
- `sources.json` records the complete used source hashes and selected control
  witnesses. Full source bytes remain in the already retained archives.
- `option-projection.json` records the relevant declarations and conclusion
  values. `option-occurrences.json` retains all matching field/key occurrences
  throughout the archive's `src/` text files, plus setter/copy call sites.
- `parser-sites.json` retains the direct parser error/warning inventory and
  the source-derived byte constants. These are lexical supports for the source
  argument, not a compiled call graph or a proof of native reachability.
- `round.json` records scope, selected model/effort, unavailable telemetry and
  actual elapsed time. `check-result.json` records the focused offline check.

Run the checker from the repository root:

```text
python3 -B docs/evidence/retained-cvc5-parser-options-20261020/check.py
```

It checks input identities, source hashes/witnesses, exact option declarations
and occurrence inventories, warning constants, and the accepted statistics
arithmetic. It does not parse a generated task, run a solver, prove semantic
acceptance or discharge the N/F/rendered-operand/internal-warning/native joins.
No complete q or O is exported. Do not interpret unchanged defaults alone as
the option-preservation proof: the research note supplies the setter, automatic
configuration, scope and copy-isolation argument.
