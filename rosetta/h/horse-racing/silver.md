# Horse racing

**Candidate: proofs likely to discharge automatically.** All data is fixed and small, so every arithmetic result is bounded by declared ranges and every array index comes from for-loop ranges over the array, with no recursion, while loops or floating point needed.

Position 793 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed the nine past-form ratings and the four adjustments as integer pound values (the 0.4 and 0.2 per-tenth-second terms are whole pounds), store ten horses in a constrained array of records (letter, rating, colt flag), and bubble-sort descending with for loops and a swap through a temporary. Print each row from integer data: positions with "=" for ties, weights chosen by sex, distances as half-length integers formatted as N.0 or N.5, and the winner's time computed in tenths of seconds and split into minutes and seconds with / and mod. About 110 lines.

## Proof obligations to watch

- **index**: The bubble-sort inner loop reads element y+1, discharged by choosing for-loop bounds of the form 1 .. N-1 over a constrained array type with no loop-carried index.
- **overflow**: Ratings are small integers in a declared subtype (about -1000..1000) updated only by constant offsets, so all additions stay within Integer.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, for loops, procedures, 'Image of scalars, string building, Put without a newline and case statements.

## External effects

- **console output** (allowed): Prints the Race 4 result table and the winner's time to standard output.

Assessed on 2026-10-15 against page revision 414256 of the [task](https://rosettacode.org/wiki/Horse_racing) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
