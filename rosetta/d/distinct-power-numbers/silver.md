# Distinct power numbers

**Candidate: proofs likely to discharge automatically.** The task has only bounded loops over constant ranges, small integer powers and a fixed-size sort, so every check follows from types and for-loop ranges with no loop-carried unbounded values or annotations.

Position 1507 in the [progression](../../progression.md#stage-30), in stage 30.

## Approach

Fill a 16-element array of Integer range 0..3125 with A**B using nested for loops over subtype 2..5, then bubble-sort it with fixed-bound for loops and swaps. Print the values in order with Put, skipping any value equal to the previous printed one, then a final newline. About 45 lines.

## Proof obligations to watch

- **overflow**: A**B with A and B in subtypes 2..5 is at most 3125, which fits Integer and an array element subtype 0..3125, so the check follows from the declared ranges.
- **index**: Compute the slot as (A-2)*4+(B-2)+1 with A and B in 2..5, and in the sort use for-loop indexes whose J+1 stays within the array range.

## Language surface beyond today's Silver

Integers, exponentiation, ranged subtypes, arrays, for loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the 15 distinct powers in ascending order.

Assessed on 2026-10-15 against page revision 382345 of the [task](https://rosettacode.org/wiki/Distinct_power_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
