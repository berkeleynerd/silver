# Generate random numbers without repeating a value

**Candidate: proofs likely to discharge automatically.** Every check follows from declared subtypes, for-loop indexes over the array's own range, and a mod whose divisor is provably positive, and no loop-carried value needs an invariant because the generator state is reduced by mod into its declared range each step. Fisher-Yates guarantees uniqueness by construction, so no retry loop or termination argument is needed.

Position 123 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A constant seed drives a linear congruential generator over a bounded subtype (0 .. 65536), and an array of subtype 1 .. 20 is filled with its own indexes. A Fisher-Yates for loop picks a swap index in I .. 20 from the generator state with mod (21 - I) and swaps two elements, so no value repeats by construction. A second for loop prints each element with 'Image and Put separated by spaces, then ends the line. About 35 lines.

## Proof obligations to watch

- **range**: The swap index I + State mod (21 - I) must lie in 1 .. 20, which follows from I's loop range and the mod bound, a mild nonlinear fact the provers should discharge.
- **overflow**: The generator step State * 75 + 74 stays far below the Integer limit because State is declared with a bounded range and is reduced by mod after each step.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The shuffled numbers 1 through 20 are printed to standard output on one line.

Assessed on 2026-10-15 against page revision 415204 of the [task](https://rosettacode.org/wiki/Generate_random_numbers_without_repeating_a_value) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
