# Egyptian division

**Candidate: proofs likely to discharge automatically.** Every check follows from bounded subtypes, array ranges and a guard placed before each doubling, with only terminating for loops and a procedure-based exit loop, so nothing needs an annotation.

Position 202 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A procedure Divide takes a Dividend subtype (0..1_000_000) and Divisor subtype (1..1_000_000) and fills two 32-element arrays, powers_of_2 and doublings, in a loop that stops when the next doubling would exceed the dividend (checked by comparing the prior row with the dividend minus that row). A second for-reverse loop over the used rows adds a doubling to the accumulator and the matching power to the answer when the sum stays within the dividend, then the remainder is dividend minus accumulator. Main calls it with 580 and 34 and prints the two results with Integer'Image concatenation. About 45 lines.

## Proof obligations to watch

- **overflow**: Each doubling is computed only after a guard that the previous row is at most half the dividend, and the dividend subtype is capped at 1_000_000, so powers, doublings, the accumulator and the answer all fit in Integer.
- **initialization**: Both 32-row tables are declared with (others => 0) aggregates so reading rows built earlier never touches uninitialized elements.
- **index**: The row counter has its own subtype 0..31 and the doubling loop exits once the dividend cap makes a 32nd row impossible, so every index is within the table range.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the quotient and remainder of 580 / 34 as a line of text.

Assessed on 2026-10-15 against page revision 415412 of the [task](https://rosettacode.org/wiki/Egyptian_division) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
