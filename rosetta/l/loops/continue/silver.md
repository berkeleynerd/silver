# Loops/Continue

**Candidate: proofs likely to discharge automatically.** The loop index is bounded by a static range and nothing is carried across iterations, so no check can fail and no annotation is needed; the only gaps are Silver_IO lacking Put without newline and integer image.

Position 871 in the [progression](../../../progression.md#stage-15), in stage 15, which adds conditional expressions.

## Approach

A single for loop over I in 1 .. 10 prints the number via Put, then an if statement prints a line terminator after 5 and 10, otherwise prints ", ". The 'continue' is expressed by structuring the if/else so the rest of the body is skipped, with no goto; Put of a trimmed integer image (leading space dropped) is needed to match the exact text. About 16 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, for loops, 'Image of scalars, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the two comma-separated lines of numbers to standard output.

Assessed on 2026-10-15 against page revision 412891 of the [task](https://rosettacode.org/wiki/Loops/Continue) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
