# Sorting algorithms/Radix sort

**Candidate: proofs plausibly discharge automatically.** All bounds are static and every loop is a for loop over fixed ranges, so checks follow from types and guards, but loop-carried counts and prefix sums need careful guards because no invariants can be written.

Position 254 in the [progression](../../../progression.md#stage-9), in stage 9.

## Approach

Embed the 8 sample integers in a constrained array of a bounded Integer subtype (about plus or minus 999_999, a documented resource limit), shift each by a constant offset to make keys nonnegative, and run a fixed number of LSD passes with base 10 using a counting sort (count array, prefix sums, stable placement into a second array) inside for loops in a procedure. Each count increment and position store is guarded, then the shifted keys are restored and printed with Put of 'Image values separated by spaces. About 80 lines.

## Proof obligations to watch

- **overflow**: Bucket counts and prefix-sum positions are loop-carried, so the program increments them only under an explicit guard (count below the array length) with a visible Reject outcome otherwise.
- **index**: Output positions computed from counts are used as array indexes, so each is checked against the array bounds immediately before the store.
- **range**: Digit extraction uses a declared bounded value subtype with a negative-to-nonnegative offset so division and mod results provably land in 0..9.
- **termination**: All loops are for loops over fixed ranges (a fixed number of digit passes), so no variant is needed.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, Put without a newline, string building and while loops.

## External effects

- **console output** (allowed): The sorted array is printed to standard output on one line.

Assessed on 2026-10-15 against page revision 413921 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Radix_sort) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
