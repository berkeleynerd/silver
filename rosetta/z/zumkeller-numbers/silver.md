# Zumkeller numbers

**Candidate: proofs plausibly discharge automatically.** Everything is bounded iteration over fixed arrays with guards before each loop-carried addition or index, and no recursion is needed because the subset-sum is a table; the difficulty is only the guard discipline and the integer-to-text output.

Position 422 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Enumerate divisors of n with a for loop into a fixed-capacity array, sum them with a guarded accumulator, and reject odd sums; for odd n use the abundance parity shortcut, otherwise run an iterative boolean subset-sum table (iterating sums downward over a bounded array) for target sigma/2. A while loop in the main procedure scans candidates (step 1 or 2) counting hits until 220 or 40 are found, formatting each number into a text buffer and printing in rows. About 150 lines.

## Proof obligations to watch

- **overflow**: The divisor sum is a loop-carried accumulator, so it is held in a 64-bit type and each addition is preceded by a guard that rejects the candidate (a visible outcome) if it would exceed a documented cap far above any sigma(n) needed.
- **index**: The subset-sum table is indexed by the running target minus a divisor, so each access is guarded by a comparison immediately before it and the table size is a fixed capacity checked against sigma(n)/2 before use.
- **range**: Divisor count is a loop-carried index into a fixed-capacity divisor array, so it is guarded against the capacity before each store, with overflow of the capacity reported as a rejection.
- **termination**: All searching, divisor enumeration and subset-sum work is done in procedures using for loops or while loops over bounded counters, so no function needs a variant.
- **other**: Search limits (n up to roughly 10^5 to 10^6 for the odd lists) are documented resource bounds, and the main search loops must stop with a specified outcome if a limit is hit before the required counts are found.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 220 Zumkeller numbers, the 40 odd ones and the 40 odd ones not ending in 5 as text lines.

Assessed on 2026-10-15 against page revision 414751 of the [task](https://rosettacode.org/wiki/Zumkeller_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
