# Square-free integers

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared integer ranges, for-loop indexes over array ranges and a guard before each window store, but 64-bit nonlinear products and the string and 'Image output machinery make it depend on careful program shape. No annotation is needed because all loops are for loops or sit inside procedures.

Position 400 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Two Boolean arrays are used, one of 1_000_001 entries for 1..10^6 and one of 146 entries for 10^12..10^12+145. Each is marked by looping d over 2..1000 for the small one and 2..1_000_000 for the window, computing the first multiple of d*d inside the window with mod and storing only when the offset is at most 145. A procedure prints the numbers in rows with Put and 'Image, and the counts at 100, 1000, 10_000, 100_000 and 10^6 come from a running count over the small array. About 90 lines.

## Proof obligations to watch

- **overflow**: Values near 10^12 and d*d for d up to 10^6 need a 64-bit integer type, and the products and the sum 10^12 + offset are bounded by the declared ranges of d and offset.
- **index**: The Boolean sieve of 1_000_001 entries is indexed by m*(d*d) with m limited to 1_000_000/(d*d), a nonlinear bound the provers may need help with, so the program instead uses a for loop over 1..1_000_000 testing n mod (d*d) = 0 against d in 2..1000, or guards idx <= 1_000_000 before each store.
- **range**: The offset (d*d - 10^12 mod (d*d)) mod (d*d) is guarded by 'if off <= 145' before it indexes the 146-entry window array, which the provers discharge from the guard.
- **division**: Every divisor d*d is at least 4 because d is a loop index over a range starting at 2.
- **termination**: All loops are for loops, or while loops inside procedures, so no termination check arises.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the square-free lists in horizontal rows and the five counts.

Assessed on 2026-10-15 against page revision 413926 of the [task](https://rosettacode.org/wiki/Square-free_integers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
