# Sum of the digits of n is substring of n

**Candidate: proofs likely to discharge automatically.** All values are bounded by declared ranges (N at most 999, digit sum at most 27) and every loop is a for loop over fixed bounds, so no invariants are needed; the only new surface is integer-to-text conversion and character-wise substring comparison.

Position 518 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

For each N in the subtype 0..999, a procedure writes N and its digit sum (0..27) into small fixed Character buffers of 3 and 2 digits with lengths computed from range comparisons, using three unrolled mod/div steps instead of a loop-carried quotient. A nested for loop compares the sum text against every window of the N text, guarded by length, setting a Boolean found flag. Matching numbers are printed with Put plus a space separator, and Put_Line ends the line. About 55 lines.

## Proof obligations to watch

- **index**: The substring scan uses for-loop offsets limited to Length(N) - Length(S) and guarded by Length(S) <= Length(N), so slice bounds follow from the guard.
- **range**: Digit extraction in a for loop over a fixed three-digit width keeps each digit in 0..9 via mod 10, and the sum is typed 0..27, so the conversion to Character is bounded by types.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, string indexing, string building, for loops, while loops, procedures, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): Prints the qualifying numbers from 0 to 999 on one line, space separated.

Assessed on 2026-10-15 against page revision 411292 of the [task](https://rosettacode.org/wiki/Sum_of_the_digits_of_n_is_substring_of_n) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
