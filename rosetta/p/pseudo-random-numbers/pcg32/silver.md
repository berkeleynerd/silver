# Pseudo-random numbers/PCG32

**Candidate: proofs likely to discharge automatically.** Everything is modular or small-range integer arithmetic in for loops and procedures, so every check follows from types and static bounds with no recursion or while loop. The only mild care points are the nonlinear bucket index bound and the loop-carried counters, both handled by types.

Position 1503 in the [progression](../../../progression.md#stage-29), in stage 29.

## Approach

Declare modular types for 64-bit state and 32-bit output, hold state and increment in in-out parameters of a seed procedure and a next procedure (side effects stay in procedures), and implement shifts as division and multiplication by powers of two with a rotation subtype 0..31. Float generation is replaced by exact integer scaling (x*5)/2**32 to pick the bucket, which equals floor(next_float*5), and counts live in a five-element array updated in a for loop over 100_000 iterations, with results printed via Put_Line and 'Image. About 80 lines.

## Proof obligations to watch

- **overflow**: The 64-bit multiply-add wraps by definition on a modular type so it carries no overflow check, and the bucket counters are modular or guarded so the loop-carried increment needs no invariant.
- **index**: The bucket index (x*5)/2**32 with x a 32-bit value is at most 4, which the provers can show from the type bound by simple nonlinear reasoning.
- **range**: The rotation amount state/2**59 lies in 0..31, which is converted into a subtype 0..31 before being used in 2**rot and 2**(32-rot).

## Language surface recorded by this assessment

Integers, integer division, exponentiation, modular types, ranged subtypes, arrays, for loops, procedures, functions, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the five generated integers and the five bucket counts to standard output.

Assessed on 2026-10-15 against page revision 413864 of the [task](https://rosettacode.org/wiki/Pseudo-random_numbers/PCG32) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
