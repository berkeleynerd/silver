# Cipolla's algorithm

**Candidate: proofs likely to discharge automatically.** The five required cases have p at most 1000003, so all arithmetic fits in 64-bit integers with range-typed residues and for loops, and every check follows from types and mod; the 50-digit extra credit is omitted as optional.

Position 798 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed the five (n, p) pairs in a constant array of a record type, with residues held in a ranged subtype of a 64-bit integer so every product of two residues is under 10^12. Modular power is a for loop over 32 exponent bits (square, then multiply if the bit is set, reducing with mod after each product), used for the Legendre symbol and for exponentiation of (a, 1) in Fp2 using a pair record; the nonsquare a is found by a deterministic for loop from 2 upward with exit when the Legendre symbol of a*a-n is p-1. Each case prints a visible outcome: both roots verified by x*x mod p = n, or a stated message when n is not a square, the Fp2 result has nonzero imaginary part, or no a is found. About 110 lines.

## Proof obligations to watch

- **overflow**: Products of two residues below p (at most 1000003) stay under 10^12 in a 64-bit type and every result is immediately reduced with mod, so range-typed operands let the provers discharge it despite the nonlinear multiplication.
- **range**: Loop-carried accumulators in modular exponentiation are declared as a residue subtype 0..1000002 and each assignment is a mod result, so the range check follows from the type and the mod bound.
- **termination**: The exponentiation and the search for a use for loops over fixed bit counts and a bounded candidate range with exit, and the search is a procedure with an explicit not-found outcome, so no variant is needed.
- **division**: Every mod and division uses the constant modulus p taken from the embedded table whose subtype excludes zero, so the divisor is provably nonzero.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, case statements, procedures, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the solutions or the no-solution message for each of the five required (n, p) cases.

Assessed on 2026-10-15 against page revision 405188 of the [task](https://rosettacode.org/wiki/Cipolla's_algorithm) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
