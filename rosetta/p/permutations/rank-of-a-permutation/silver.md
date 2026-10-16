# Permutations/Rank of a permutation

**Candidate: proofs plausibly discharge automatically.** The algorithm is iterative array swapping with small integer ranges and 12! fits in 64 bits, so every check follows from types and a few guards, but the loop-carried rank accumulator and the LCG need careful range shaping.

Position 942 in the [progression](../../../progression.md#stage-16), in stage 16.

## Approach

Permutations are fixed-capacity arrays of a 0..11 subtype with an inverse array, and 12! plus a factorial table are constants in a 64-bit range type. Unrank is an iterative for loop (reverse n..1) doing swap(n-1, r mod n) and r := r / n, rank is an iterative loop with s := pi(n-1), swaps and an accumulated value, and a deterministic LCG supplies four ranks mod 12!. Main prints the n=3 round trip (all 6 ranks) and the four 12-element samples through procedures that build text lines with 'Image. About 130 lines.

## Proof obligations to watch

- **overflow**: The rank accumulator is loop-carried with no invariant, so the program guards each step against a fixed bound on the 64-bit rank type (or uses a precomputed factorial constant table) and rejects out-of-range values visibly.
- **index**: Swap positions come from r mod n and from inverse-array entries, which are safe because the element and index subtypes are declared as 0..11 and n is a for-loop index of at least 1.
- **range**: Pseudo-random ranks must land in 0..12!-1, which is achieved by taking a mod 12! of an LCG state held in a wide range type so the multiply cannot overflow.
- **termination**: All loops are for loops or live in procedures, and the Myrvold-Ruskey rank and unrank are written iteratively, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building, Put without a newline, Boolean objects and conditional expressions.

## External effects

- **console output** (allowed): Prints the n=3 rank/permutation round-trip table and four 12-object samples with their ranks.

Assessed on 2026-10-15 against page revision 413847 of the [task](https://rosettacode.org/wiki/Permutations/Rank_of_a_permutation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
