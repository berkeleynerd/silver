# Numeric separator syntax

**Candidate: proofs likely to discharge automatically.** The numeric-separator candidate admitted on 2026-11-18 using current syntax and output forms. There is no measured missing string-building operation for this approach, and no proof/build/execution claim follows from its admission result. The original surface mapping is retained for separate coverage reconciliation; these observations add no delivered sample or supported task mapping in this batch.

Position 105 in the [progression](../../progression.md#stage-4), in stage 4.

## Approach

The planning candidate prints the Ada underscore rules and demonstrates separated in-range Integer literals alongside separator-free values, using existing Integer comparisons and Integer Image in fixed-text output. It needs no computed-length output buffer. The measured result is admission only. About 25 lines.

## Language surface recorded by this assessment

Integers, 'Image of scalars and string building.

## External effects

- **console output** (allowed): The program prints the description of the separator rules and the demonstrated values with Put_Line.

Initially assessed on 2026-10-15 against page revision 413863 of the [task](https://rosettacode.org/wiki/Numeric_separator_syntax) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-18 by Codex through targeted source review; see the [review record](../../../docs/bounded-string-building-samples.md).
