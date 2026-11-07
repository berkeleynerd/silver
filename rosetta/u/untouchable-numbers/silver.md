# Untouchable numbers

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed array bounds, for-loop indexes and a saturating cap on the accumulator, so only the nonlinear index i*k and the large sieve size need careful shaping; no annotation is needed, but counts at 10,000 and above are impractical and are treated as optional.

Position 267 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Keep a constrained Boolean array Touched over 1..2000 and a sieve array of saturating aliquot sums over 1..4,000,000, built with nested for loops (for each i, for k in 2 .. Limit/i add i to the sum at i*k, capped at 2001). Then mark Touched(sum) for every n whose capped sum is at most 2000, and print the untouchable numbers in a 16-column grid using integer-to-text into a bounded buffer, followed by the total count and the counts up to 10, 100 and 1000 computed with a running counter in a single for loop. About 90 lines.

## Proof obligations to watch

- **overflow**: Each aliquot-sum accumulator element is loop-carried through the nested sieve, so the program saturates it at a cap just above 2000 (which cannot change any result since only sums up to 2000 matter) so the addition is guarded and provably in range.
- **index**: The multiple index i*k is nonlinear, so the loop runs k over 2 .. Limit/i and the bound i*k <= Limit must be dischargeable by the provers from that range, with a guard before indexing as fallback.
- **range**: A sieve bound of about 4 million (sufficient since any aliquot sum v needs n <= v*v) makes a large static array and a harmonic-sum loop count that only terminates trivially because for loops are used, so counts beyond 1000 or 2000 must be dropped as impractical.
- **termination**: All loops are for loops or while loops inside procedures, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The grid of untouchable numbers up to 2000 and the counts are printed to standard output.

Assessed on 2026-10-15 against page revision 414021 of the [task](https://rosettacode.org/wiki/Untouchable_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
