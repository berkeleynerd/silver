# Multiplication tables

**Candidate: proofs likely to discharge automatically.** The source computes the complete 12-by-12 upper triangle, including its diagonal, with a header and aligned row labels. The manifest specifies 13 lines of 52 bytes before LF; no Character operations, digit buffer, helper procedure or general string building is used. The exact source passed admission, complete required application/library proof audit, build and manifest execution in integration run 20261107T164659-9f6192441d21; the linked assessment records the evidence scope. The linked delivery record carries the independent closing review status.

Position 64 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main prints twelve column headings and then rows 1 .. 12. Nested counted loops print four spaces when Column < Row, otherwise compute Product := (Row * Column) in range 1 .. 144. Conditional literal padding and Integer Image give each heading and product a four-character field. About 38 lines.

## Proof obligations to watch

- **range**: Both product operands are in 1 .. 12, so the assignment fits Product range 1 .. 144; scalar guards select padding without changing the computed product.

## Language surface recorded by this assessment

Put without a newline, Integer range for loops, immutable Integer arithmetic, Integer image, bounded mutable Integer objects and scalar guard refinement.

## External effects

- **console output** (allowed): Prints a header and twelve aligned upper-triangle table rows, each 52 characters wide before its line terminator.

Initially assessed on 2026-10-15 against page revision 414747 of the [task](https://rosettacode.org/wiki/Multiplication_tables) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-07 by Codex through targeted source review; see the [review record](../../assessment-sample-expansion-20261107.md).
