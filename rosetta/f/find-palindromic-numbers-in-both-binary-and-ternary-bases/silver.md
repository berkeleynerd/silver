# Find palindromic numbers in both binary and ternary bases

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed-size digit arrays, bounded for loops and a capped 64-bit accumulator guard, though the loop-carried value accumulation needs careful guard placement and the 90396755477 target requires 64-bit integers.

Position 259 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Generate base-3 palindromes in ascending order by digit length (1..25) and half-value k, building the ternary digit array and its value with a guarded Horner loop, then extract binary digits into a fixed 64-element array and test symmetry with a for loop over half the length. Counts matches in a procedure, stops after six (embedding 0 and 1 as the first results is permitted but not needed), and prints each decimal value via image conversion; roughly 3 million candidates are examined at run time. About 90 lines.

## Proof obligations to watch

- **overflow**: Horner-style accumulation of the base-3 palindrome value in a loop has no invariant, so it is bounded by a 64-bit type with a guard before each multiply-add that stops the candidate visibly if the cap (3**26) is exceeded.
- **index**: Digit arrays of fixed size 64 are indexed by loop counters; the counter's subtype range or a guard against the capacity just before each store discharges it, since digit counts are loop-carried.
- **range**: Digit extraction by repeated division by 2 or 3 in a loop relies on a for loop with a fixed iteration bound rather than 'while n > 0' so counts stay within array bounds.
- **termination**: All loops live in procedures (no termination check), and the search is a bounded for loop over lengths 1..25 with k limited by a precomputed power-of-3 table.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, for loops, while loops, Boolean objects, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the six decimal results, one per line.

Assessed on 2026-10-15 against page revision 413719 of the [task](https://rosettacode.org/wiki/Find_palindromic_numbers_in_both_binary_and_ternary_bases) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
