# Even or odd

**Candidate: proofs likely to discharge automatically.** The only arithmetic is rem 2 on a value bounded by a declared range inside a for loop, so no overflow, division or index check needs more than the type range, and no annotation is needed. The only growth needed is ranged integers, rem, a for loop and integer-to-text output.

Position 111 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Declare a bounded integer subtype (for example -1000 .. 1000) and loop with a for loop over that range, testing N rem 2 = 0 for even and printing the number with its 'Image and the verdict via Put_Line. Every value is bounded by its type, so rem and 'Image checks follow from declared ranges, with no recursion or loop-carried state. About 22 lines.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, for loops, 'Image of scalars, Put without a newline and procedures.

## External effects

- **console output** (allowed): Prints whether each sample integer is even or odd.

Assessed on 2026-10-15 against page revision 415382 of the [task](https://rosettacode.org/wiki/Even_or_odd) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
