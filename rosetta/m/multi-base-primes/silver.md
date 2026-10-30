# Multi-base primes

**Candidate: proofs plausibly discharge automatically.** Every check follows from constant bounds, 64-bit headroom and guards before use, and there are no while loops, recursion or annotations, but guarded Horner arithmetic and bounded output buffers inside nested loops need careful shape.

Position 624 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

For each length 1 to 4, a for loop counts through all values below 36**n, decodes each into a digit array with mod and /, skips leading zeros, and for each base above the largest digit evaluates the digits by guarded Horner arithmetic and tests primality by trial division in a for loop. The best count and a fixed-capacity array of tied records (digit string plus a Boolean flag per base 2..36) are updated, then printed using bounded string building and Integer'Image. The 5-character stretch goal is left out because it needs about 60 million strings. About 140 lines.

## Proof obligations to watch

- **overflow**: Horner evaluation of a digit string in a base carries a loop-carried value, so it is held in a 64-bit type and guarded before each multiply, which is harmless because values never exceed 36**5.
- **overflow**: Primality uses a for loop of divisors up to a constant 6000 with a guard d*d <= v and an early exit, so no loop-carried quantity needs an invariant.
- **index**: The tie list and the base-list text buffer have fixed capacities that are checked before each store, with a visible Reject outcome if a limit would be exceeded.
- **range**: Digit values 0..35 are converted to characters through guarded 'Pos/'Val arithmetic on constrained digit subtypes, and the odometer counter is decoded by mod and / with constant divisors.
- **termination**: Only for loops are used, so no variant is needed; the work (about 1.7 million 4-digit strings times 35 bases) is a runtime cost, not a proof issue.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, for loops, procedures, functions, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints each string, its base count and its list of bases with Put_Line.

Assessed on 2026-10-15 against page revision 413794 of the [task](https://rosettacode.org/wiki/Multi-base_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
