# Ludic numbers

**Candidate: proofs plausibly discharge automatically.** All arrays are statically bounded, and every loop-carried counter can be kept in range with an explicit guard before use, so no annotation is needed, but the many guarded counters and the Image-based text building require careful program shape.

Position 278 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Use a Boolean Removed array over 1..22000 and a ludic result array of fixed capacity; each round finds the first unremoved value L, records it, then a for loop over the whole array counts survivors with a guarded counter and marks every L-th one removed, stopping when no survivor beyond the current one remains. Counting up to 1000, printing ranges and checking triplets are for loops with a membership lookup over the stored ludic array, and every output line is built with 'Image text into a bounded buffer. About 110 lines.

## Proof obligations to watch

- **overflow**: The loop-carried survivor counter and result count are bounded only by their subtype ranges, so each increment sits behind an explicit guard that rejects instead of altering results.
- **index**: The ludic result array index is a loop-carried count, so a guard against capacity precedes each store, with a visible Reject outcome.
- **termination**: All loops live in procedures, and the sieve uses for loops over the fixed 1..22000 range, so no termination check or variant is needed.
- **length**: Output lines built from 'Image fragments need bounded buffers sized for the maximum number of digits and items per line.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 25 ludic numbers, the count up to 1000, the 2000th to 2005th numbers and the triplets below 250.

Assessed on 2026-10-15 against page revision 414316 of the [task](https://rosettacode.org/wiki/Ludic_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
