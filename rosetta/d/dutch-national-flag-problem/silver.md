# Dutch national flag problem

**Candidate: proofs likely to discharge automatically.** Every loop is a for loop over a static range, all state is bounded by declared types, and the only loop-carried values (counters, write position, generator state) can be range-bounded or guarded, so no annotations are needed. The sort is a counting sort rather than the swap-based Dijkstra partition, since the latter needs loop invariants to bound its three indices.

Position 1164 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Balls are a fixed-capacity array of 12 over an enumeration (Red, White, Blue), filled by a linear congruential generator in a for loop; if the result happens to be sorted, the first ball is set to Blue and the last to Red so it is visibly unsorted. The sort counts each color in a for loop, then refills the array in a for loop per color with guarded positions, and an Is_Sorted function checks adjacent pairs. Output goes through Put_Line of a text line assembled in a bounded buffer from the color names, before and after, followed by a sorted-check line. About 90 lines.

## Proof obligations to watch

- **overflow**: The deterministic generator state is a bounded range type and each step is computed in a wider ranged type with a mod, so the product cannot overflow.
- **overflow**: The per-color counters are loop-carried, so each increment sits behind an explicit guard against the array capacity, with the guard's alternative leaving the counter unchanged.
- **index**: The write position in the counting-sort refill is loop-carried, so it is guarded against the last array index before each store and the loops run over the array's own range.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, enumerations, arrays, for loops, procedures, functions, Boolean objects, conditional expressions, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the original and sorted ball orders and the check result.

Assessed on 2026-10-15 against page revision 415411 of the [task](https://rosettacode.org/wiki/Dutch_national_flag_problem) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
