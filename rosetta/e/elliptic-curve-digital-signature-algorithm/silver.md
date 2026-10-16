# Elliptic Curve Digital Signature Algorithm

**Candidate: proofs plausibly discharge automatically.** The toy ECDSA only needs bounded 64-bit modular arithmetic and loops in procedures, so no annotation is required, but loop-carried extended-gcd coefficients and nonlinear modular products need careful guards and subtypes.

Position 647 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Curve parameters, points (with an infinity flag) and signature pairs are records, and the embedded test vectors sit in a constant array; moduli are validated to at most 30 bits and all residues live in ranged subtypes. Point addition, double-and-add multiplication and extended-gcd inversion are procedures that return an error flag, with the loops bounded by for loops over bit counts or guarded while loops, and a deterministic LCG supplies the private key and one-time u. The main procedure loops over the vectors checking the curve, base point and order, then signs, optionally tampers the hash by adding a value mod r, verifies, and prints Valid or invalid with Put_Line and 'Image concatenation. About 260 lines.

## Proof obligations to watch

- **overflow**: Modular products and the lambda and discriminant formulas are bounded by keeping every residue in a subtype below 2**30 so each product fits in 64 bits, with parameter validation rejecting larger moduli before any arithmetic.
- **overflow**: The extended-gcd loop carries Bezout coefficients whose bounds only an invariant could state, so the program guards each q*s and subtraction step and reports impossible inverse if a guard would fail, which never triggers for valid residues.
- **termination**: Extended gcd and double-and-add use a bounded for loop (about 64 iterations with early-exit flag) or a while loop inside a procedure, so no variant is needed and no function contains a while loop.
- **division**: Every division and mod is preceded by an explicit nonzero check on the divisor (modulus, v in the gcd loop) with a visible rejection outcome.
- **range**: Pseudo-random draws from a deterministic LCG are reduced mod r-1 plus 1 into a ranged subtype, and the order r is validated in range first.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, records, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The program prints the curve parameters, keys, signature and Valid/invalid verdict for each embedded test vector.

Assessed on 2026-10-15 against page revision 413701 of the [task](https://rosettacode.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
