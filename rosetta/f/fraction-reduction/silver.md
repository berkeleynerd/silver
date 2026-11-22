# Fraction reduction

**Candidate: proofs plausibly discharge automatically.** Every operation is a for loop over fixed-size digit arrays with bounded subtypes, so range, index and termination checks follow from types, and the only non-routine items are loop-carried counters and the bounded nonlinear product. No annotations or recursion are needed, but careful counter typing makes it plausible rather than likely.

Position 727 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed the size limits (12..97, 123..986, 1234..9875, optionally 12345..98764) in a constant table, and for each size loop n and then d>n with for loops, extracting digits into a fixed Digit_Array via a fixed-count for loop with mod/div by 10, rejecting numbers with a zero or repeated digit. For each shared digit, remove it from both numbers using a constant powers-of-ten table, test n*rd = rn*d in a bounded integer subtype, and on a match bump the size count and per-digit count and print the first twelve lines built from 'Image concatenation with Put_Line. After each size, print the count and the nonzero per-digit counts. About 130 lines.

## Proof obligations to watch

- **overflow**: The per-size and per-digit counters are loop-carried across nested loops, so they need a range type with an explicit saturation guard or a count type wide enough that the iteration bound is obvious from the loop ranges.
- **overflow**: The cross-multiplication n*rd = rn*d is nonlinear but discharges because n, d, rn and rd are subtypes bounded by 99999 and the product fits in 64 bits.
- **index**: Digit extraction and removal index a fixed-size digit array by loop-carried positions, which discharges by using for loops over the array's own range and subtype-typed digit values 1..9 for the count table.
- **range**: Repeated n/10 and mod 10 on loop-carried values stay within the integer subtype because division only shrinks them, and the power of ten is taken from a constant table rather than loop-carried exponentiation.
- **termination**: All iteration is for loops (digit extraction uses a fixed-count for loop rather than while n>0), so no variant is needed; the search loops over n and d are for loops in procedures.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, 'Image of scalars, string building, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): Prints the first twelve examples, the count and the per-digit crossed-out counts for each size, one line at a time.

Assessed on 2026-10-15 against page revision 413727 of the [task](https://rosettacode.org/wiki/Fraction_reduction) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
