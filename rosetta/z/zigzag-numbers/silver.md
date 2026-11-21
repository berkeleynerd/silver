# Zigzag numbers

**Candidate: proofs plausibly discharge automatically.** Everything is iterative with bounded arrays and for loops, and the only unusual parts are the add-with-carry big number (A(30) exceeds 64 bits) and guarded while-loop scans in procedures, none of which needs an annotation.

Position 1382 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Permutations of 1..n (n at most 5) are enumerated in lexicographic order with an iterative next-permutation procedure over a fixed 5-element array, printing those with the up-down pattern; n of 1 prints the single permutation. Counts for m from 1 to 30 come from the Seidel/Entringer triangle built with for loops using only additions on a fixed-capacity two-limb big number held in a two-dimensional array, and are printed by converting limbs to digit text. About 170 lines.

## Proof obligations to watch

- **overflow**: A(30) is about 4e26, beyond 64 bits, so counts use a fixed-capacity two-limb base-10^18 number whose limb sums stay below 2*10^18 and carries are 0 or 1, which follow from the limb subtype ranges.
- **index**: The next-permutation scan loops decrement an index in while loops, so each decrement is guarded by an explicit index-greater-than-first test before the array access.
- **range**: Entringer-table row and column indexes come from for loops over the array's own ranges, but the loop-carried big-number cells are only bounded by their limb types, which suffices for the additions.
- **length**: Rendering a two-limb number into a decimal text buffer needs a fixed 27-digit buffer with padded limb digits so slice lengths are static.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, for loops, while loops, procedures, big numbers, Put without a newline, 'Image of scalars, string building and Boolean objects.

## External effects

- **console output** (allowed): Prints the permutations for n from 1 to 5 and the counts for m from 1 to 30 as text lines.

Assessed on 2026-10-15 against page revision 401063 of the [task](https://rosettacode.org/wiki/Zigzag_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
