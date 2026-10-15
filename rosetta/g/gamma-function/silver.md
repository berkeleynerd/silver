# Gamma function

**Candidate: proofs plausibly discharge automatically.** All indexing and loop control follow from the array range and for loops, but the Horner accumulator is a loop-carried float needing bounded-subtype guards and the reciprocal needs a zero guard, so discharge depends on careful shape with no annotation required.

Position 1066 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed the 30 Taylor coefficients of 1/Gamma(x+1) as a constant Float array and evaluate by a reverse for-loop Horner scheme in a function over an argument subtype with a modest range, with Sum held in a bounded subtype and each step checked by a guard before assignment. A main procedure loops I in 1..10, computes Gamma(I/3.0), guards the reciprocal against zero, and prints the result with a float image. About 70 lines.

## Proof obligations to watch

- **floating point**: Every Horner step Sum*Y+A(N) has an overflow check on a loop-carried float that only a type range or guard can bound, so Sum gets a bounded subtype and each step is computed into a temporary and rejected visibly if it leaves the bound.
- **overflow**: Y is restricted to a small ranged subtype and Sum to a bounded range so the product cannot overflow, but the prover must handle float multiplication bounds with no invariant, which is the fragile part.
- **division**: The final 1.0 / Sum is guarded by an explicit test that Sum is not zero (and not tiny) with a specified rejection outcome.
- **range**: The integer-to-float conversion of I and the division by 3.0 stay within the declared Gamma argument subtype because I is fixed to 1..10.

## Language surface beyond today's Silver

Floating point, floating-point images, arrays, for loops, ranged subtypes, integers, functions, procedures and Put without a newline.

## External effects

- **console output** (allowed): The program prints Gamma(I/3) for I in 1..10 as text lines.

Assessed on 2026-10-15 against page revision 414229 of the [task](https://rosettacode.org/wiki/Gamma_function) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
