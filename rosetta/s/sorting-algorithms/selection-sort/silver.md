# Sorting algorithms/Selection sort

**Candidate: proofs likely to discharge automatically.** Selection sort over a fixed-size array uses only for loops with static bounds and indices drawn from the array's own range, so index and range checks discharge from types without invariants; the output formatting is the only extra surface.

Position 90 in the [progression](../../../progression.md#stage-4), in stage 4.

## Approach

Embed the ten example values in a constrained array of a declared bounded integer subtype indexed by 1..10, and sort it in a procedure with nested for loops over fixed constant ranges, tracking the minimum index in a variable of the index subtype and swapping through a temporary. Then print each element with a for loop, using 'Image output through Put_Line (or Put). No while loops, recursion, or contracts are needed because all loop bounds are static and every index comes from the array's own range. About 45 lines.

## Proof obligations to watch

- **index**: Index into A(Min) and A(J) stays safe because Min is typed as the array's index subtype and J ranges over the array's own indices, with the outer loop bounded by a constant range.
- **overflow**: Integer image formatting is the only arithmetic, and element values are a bounded subtype so the 'Image buffer length is statically sufficient.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, procedures, Put without a newline, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the sorted array as text lines via Silver_IO.

Assessed on 2026-10-15 against page revision 414505 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Selection_sort) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
