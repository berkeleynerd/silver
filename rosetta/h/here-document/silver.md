# Here document

**Excluded from Silver: outside SPARK.** Ada 2022 string literals cannot contain line breaks, and the captured Ada answer explicitly labels its alternative a workaround. This exclusion concerns native heredoc syntax under the fixed editions, not the ability to output multiline text.

## Approach

Record that the inherited language has no heredoc syntax and therefore no faithful executable Silver example for this task. Put_Line sequences and containers of strings are output workarounds, not demonstrations of the required text-block authoring syntax.

## Oracle conflicts

- **outside SPARK**: The task requires native heredoc text-block syntax, absent from the fixed Ada 2022/SPARK language, and adding it would violate Silver's subtractive-source rule.

Initially assessed on 2026-10-15 against page revision 411758 of the [task](https://rosettacode.org/wiki/Here_document) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-reconciliation-20261025.md).
