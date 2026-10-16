# Magic constant

**Candidate: proofs likely to discharge automatically.** "Every check follows from the bounded order subtype and static loop ranges, and the 10^10 search fits in 64-bit integers, so no invariant is needed."

Position 1508 in the [progression](../../progression.md#stage-30), in stage 30.

## Approach

"Declare a subtype of Long_Long_Integer for orders 3..3000 and a Magic function computing N*(N*N+1)/2 with bounded operands. Use a for loop over 3..22 and a line for order 1000, each printing 'Image text concatenated into bounded output lines. For each power p in 1..10, a for loop over orders with an exit on the first constant greater than 10**p prints the order, with an explicit visible not-found line if the loop ends without a hit; the optional 10^11 to 10^20 stretch is omitted." About 45 lines.

## Proof obligations to watch

- **overflow**: n*(n*n+1) is nonlinear but n is a subtype bounded to 3..3000 so the result is at most about 1.4e10 and fits in 64 bits, which provers discharge from the type range.
- **range**: The threshold 10**p with p in 1..10 has a static-range exponent and the search covers orders up to 3000, beyond the required 2715, with a visible not-found line if the loop ends without a hit.

## Language surface recorded by this assessment

Integers, integer division, exponentiation, ranged subtypes, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the first 20 constants, the 1000th constant and the orders for thresholds 10^1 to 10^10 line by line.

Assessed on 2026-10-15 against page revision 413773 of the [task](https://rosettacode.org/wiki/Magic_constant) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
