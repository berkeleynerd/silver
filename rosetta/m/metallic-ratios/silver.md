# Metallic ratios

**Candidate: proofs plausibly discharge automatically.** All arithmetic is small-range or fixed-capacity digit-array work inside bounded for loops, so checks should follow from types and guards, but the carried big-number arithmetic and long division make discharge depend on careful program shape. Nothing requires an annotation, recursion, or heap use.

Position 1379 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Represent each Lucas term as a fixed-capacity array of decimal digits (about 40 digits) with add, multiply-by-small-integer, compare and subtract helpers written as procedures. For each b in 0..9 a bounded for loop advances the sequence, prints the first 15 terms, and computes the ratio of consecutive terms to 32 places by digit-by-digit long division into a 32-character buffer, stopping when the string equals the previous one and printing the count. The 256-place stretch goal is omitted. About 170 lines.

## Proof obligations to watch

- **overflow**: Terms for b=9 exceed 64 bits within the needed iterations, so they live in fixed-capacity decimal digit arrays whose carries are bounded by digit-type ranges and a capacity chosen above the largest term.
- **index**: Digit-array loops index with for loops over the array's own range, but carry propagation past the top digit needs an explicit overflow-rejecting guard before the write.
- **termination**: The convergence search is an outer for loop with a fixed iteration cap above the 80 needed for b=1, so no variant is needed.
- **range**: Each long-division digit is found by at most 9 guarded subtractions of a fixed-capacity number, so the digit stays in 0..9 through a guard rather than a proof-derived invariant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, for loops, while loops, procedures, functions, string building, 'Image of scalars, big numbers and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 15 terms, the 32-place approximation and the iteration count for each b from 0 to 9.

Assessed on 2026-10-15 against page revision 414340 of the [task](https://rosettacode.org/wiki/Metallic_ratios) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
