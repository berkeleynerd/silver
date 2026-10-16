# Largest palindrome product

**Candidate: proofs likely to discharge automatically.** Every check follows from declared subtype ranges, for-loop indexes over fixed array ranges and bounded products, so no loop invariant or variant is needed and the work stays in loops inside procedures or terminating for loops.

Position 340 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Two nested for loops (reverse 100..999 for a, reverse 100..a for b) form each product in a subtype 0..999999, and a helper function copies its six decimal digits into a fixed Digits array with a for loop of n mod 10 and n / 10, then compares digit i with digit 7 - i. A palindrome larger than the current best (initially 0, so a 5-digit palindrome would also count correctly via leading-zero-aware digit count) updates the best product and factors, and the main procedure prints them with Integer'Image; the 4 to 7 digit stretch would reuse the same shape with a 64-bit range and 14-digit array, while the unbounded extension is out of scope under fixed limits. About 55 lines.

## Proof obligations to watch

- **overflow**: Products of two values in subtype 100..999 are at most 998001, which fits Integer, and digit extraction uses n mod 10 and n / 10 on a subtype 0..999999 so nothing can overflow.
- **index**: Digit arrays are indexed only by for-loop variables over the array's own 1..6 range, and the palindrome comparison pairs index i with 7 - i for i in 1..3, which the prover can bound statically.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, procedures, Boolean objects, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the two factors and the largest palindromic product.

Assessed on 2026-10-15 against page revision 397933 of the [task](https://rosettacode.org/wiki/Largest_palindrome_product) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
