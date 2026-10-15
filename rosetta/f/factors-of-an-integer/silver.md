# Factors of an integer

**Candidate: proofs likely to discharge automatically.** Trial division with a for loop over a declared Positive range needs no loop-carried state, so division and range checks follow from types and loop bounds and no annotation is needed.

Position 122 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Embed a constant array of example positive integers (e.g. 45, 53, 64, 360) and a procedure that, for each, runs a for loop over divisors 1 .. N, testing N mod D = 0 and printing each divisor with Put/Put_Line using 'Image. Input is not read, so no validation is needed; the loop index is the only loop-carried value and its bounds come from the range. About 30 lines.

## Proof obligations to watch

- **division**: The divisor is the for-loop index over 1 .. N with N of subtype Positive, so it is never zero and the mod check discharges from the loop range.
- **overflow**: Numbers are declared in a bounded Positive subtype and the loop only uses the index and mod, so no loop-carried arithmetic can overflow.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, for loops, 'Image of scalars, Put without a newline and procedures.

## External effects

- **console output** (allowed): Prints each example number's factors as text lines.

Assessed on 2026-10-15 against page revision 413796 of the [task](https://rosettacode.org/wiki/Factors_of_an_integer) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
