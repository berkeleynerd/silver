# Permutation test

**Candidate: proofs plausibly discharge automatically.** Every check follows from array ranges, constant divisors and bounded sums with guards, with no recursion or heap, but the loop-carried sums and counters and the bit-extraction arithmetic need careful guard placement.

Position 177 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Embed the 19 effect values in a constant array (treatment first), and for each mask from 0 to 2**19-1 in a for loop count its set bits and sum the selected values with an inner for loop over the 19 positions; masks with exactly 9 bits set are compared by integer sum against the observed treatment sum (equal group sizes make mean comparison equivalent to sum comparison). Counts for less-or-equal and greater are kept in bounded subtypes with guards that Reject on overflow, then percentages are computed as 1000*count/total and printed as integer part and one decimal via 'Image concatenation with Put_Line. About 70 lines.

## Proof obligations to watch

- **overflow**: The loop-carried subset sum and the two counters need explicit guards (or tight ranged subtypes with a Reject outcome) because without an invariant the prover only knows their type ranges.
- **index**: Selecting element K of the 19-value pool from the bit pattern of the loop index uses for-loop indexes over the array's own range, so the index checks are routine.
- **division**: Bit extraction by division and mod uses constant nonzero divisors, and the percentage divides by a total that is guarded to be nonzero before use.
- **range**: The one-decimal percentage 1000*count/total stays in range if counts are held in a subtype bounded by 524288.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, 'Image of scalars, string building, procedures and Boolean objects.

## External effects

- **console output** (allowed): Prints the two counts and their percentages.

Assessed on 2026-10-15 against page revision 413846 of the [task](https://rosettacode.org/wiki/Permutation_test) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
