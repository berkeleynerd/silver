# CVC5 quiet/no-statistics route packet

This offline packet supports [the source argument](../../research/retained-cvc5-quiet-route.md)
for #119 / #153 at base `421486c4e33271c02fc59f54d71182cc98c9558c`.
The preferred route directly supplies a materialized base `why3.conf` to the
existing gnatwhy3/server interface. Stock GNATprove regenerates that file;
production integration is a separate unfinished obligation.

- `candidate-base-why3.conf` and `candidate-base.diff` retain the exact one-field
  prospective edit of `put_line/why3.conf` in the existing observations archive.
  Only the ordinary command of built-in CVC5 changes: identified absolute binary,
  one quiet flag, no stats flag. Zero steps makes the unchanged step variant
  unreachable. This file was not installed or used for a native run.
- `candidate-extra-why3.conf` retains the unchanged private driver-locator config.
  It belongs beside the accepted four private driver files when constructing the
  prospective invocation; it defines no prover override.
- `route.json` records the exact string/shape delta and missing joins.
- `sources.json` retains complete used source identities and exact witnesses.
  Source bytes remain in the named pre-existing archives.
- `option-occurrences.json` checks complete matching source inventories for
  relevant fields/keys, stream reassignment and verbosity calls. These lexical
  witnesses support the note's control argument; they are not a compiled graph.
- `driver-response-directives.json` inventories the existing selected CVC5
  import closure, including the time expression and absent step directives.
- `alternative-plugin-directory.json` is a static name listing for the deferred
  custom-prover alternative, not a claim that any plugin was loaded.
- `inputs.json`, `round.json` and `check-result.json` identify reused inputs,
  selected author settings, measurement scope and actual offline checks.

From the repository root:

```text
python3 -B docs/evidence/retained-cvc5-quiet-route-20261020/check.py
```

The check verifies identities, the exact config diff, fixed token/byte arithmetic,
source witnesses/occurrences, selected response directives and local link targets.
It does not run a solver or discharge source/native behavior, complete q,
termination, prefix heaps, producer/report orchestration or current-grammar
coverage. The global two-callback/three-save/e≤2 budget is unchanged.
