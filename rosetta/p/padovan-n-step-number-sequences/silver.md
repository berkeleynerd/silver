# Padovan n-step number sequences

**Candidate: proofs likely to discharge automatically.** Everything is small fixed-bound for-loop arithmetic over constant-size arrays with values far below the integer range, so no loop invariant is needed; the only new surface is arrays, loops, integer images and procedures.

Position 78 in the [progression](../../progression.md#stage-5), in stage 5.

## Approach

Fixed constant bounds (t=15, n 2..8) with a Term array indexed 1..15; a procedure Fill(N, P) sets the first N+1 terms to the previous-order start by iterating orders 2..N non-recursively (initial all ones, then for each order k extend terms k+1..t by summing terms i-2 down to i-k-1 with for loops). Main loops n from 2 to 8, calls Fill, and builds each output line in a bounded String buffer using 'Image of each term before Put_Line. About 55 lines.

## Proof obligations to watch

- **overflow**: The array element type is a bounded integer range and the recurrence sums at most 9 earlier terms of the 15-term sequence (values under 400), so a declared range such as 0 .. 1_000_000 with a wider intermediate sum type lets the addition discharge without any invariant.
- **index**: Loop indexes i and j run over fixed constant ranges (j from i-2 down to i-n-1) with n in 2..8, which are all within 1..15 for i>=n+1, so the indexes follow from static bounds and for-loop ranges.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints a header line and seven lines of 15 terms each.

Assessed on 2026-10-15 against page revision 412025 of the [task](https://rosettacode.org/wiki/Padovan_n-step_number_sequences) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
