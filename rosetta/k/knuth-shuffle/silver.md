# Knuth shuffle

**Candidate: proofs likely to discharge automatically.** Every check follows from declared ranges, for-loop indexes over the array's own range and a mod by a positive divisor, so no annotation is needed, and the only slightly non-routine step is bounding j within 0..i.

Position 135 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

An array of ten integers indexed 0..9 is embedded as a constant aggregate and copied into a variable, and a small linear congruential generator over a ranged Seed subtype with a fixed seed replaces system randomness. A reverse for loop over 1..Last draws j as state mod (i+1), converted to the index subtype after a guard, and swaps items(i) with items(j) through a temporary. The array is printed before and after with Integer'Image in a for loop over the array's own range. About 45 lines.

## Proof obligations to watch

- **range**: The swap index j = state mod (i+1) must be shown within 0..i, which needs the prover to handle mod by a loop-variable divisor, and it discharges because i+1 is positive and the result is bounded by the divisor, with a guard on j if needed.
- **overflow**: The generator update state*75+74 is a loop-carried value, but a ranged Seed subtype of 0..65536 keeps the product within Integer and the mod by a constant brings it back into the subtype.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, 'Image of scalars and procedures.

## External effects

- **console output** (allowed): The program prints the array before and after shuffling.

Assessed on 2026-10-15 against page revision 414291 of the [task](https://rosettacode.org/wiki/Knuth_shuffle) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
