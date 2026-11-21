# Arithmetic/Rational

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged types, 64-bit intermediates and guards before divisions and narrowing, with no recursion (GCD is a bounded for loop) and no annotations, but the accumulated Rational sum across loop iterations requires careful range guarding.

Position 1464 in the [progression](../../../progression.md#stage-27), in stage 27.

## Approach

A Rational record holds a numerator and a positive-ranged denominator, with operations (negate, abs, add, subtract, multiply, divide, compare, equality, integer coercion) written as procedures or non-looping functions that normalize through an iterative bounded GCD and return a Valid flag when a zero denominator or out-of-range result occurs. The main procedure loops candidates from 2 to 2**19-1 with a for loop, finds divisor pairs d up to a fixed bound, sums 1/d and 1/(n/d) as Rationals including 1/n, and prints those whose sum equals 1. Integer-ranged types and guards before each division or narrowing conversion keep all intermediates in 64 bits. About 170 lines.

## Proof obligations to watch

- **overflow**: Cross-multiplications in add, subtract and compare are done in a 64-bit type over 32-bit ranged operands so the products and sums fit by type range alone.
- **range**: Reduced results fit the component subtype only if a guard just before the assignment rejects out-of-range values, since the prover cannot know the GCD is positive without a contract.
- **division**: The GCD is a loop-carried value, so each division by it or by a denominator is preceded by an explicit nonzero guard with a specified reject outcome.
- **termination**: GCD is a bounded for loop (Euclid needs fewer than 64 steps, exiting early) so no variant is needed, and the while-style searches live in procedures.
- **discriminant**: Zero denominators are excluded by checking before constructing a Rational and reporting a visible failure status (a Valid flag out parameter).

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, records, for loops, while loops, procedures, functions, 'Image of scalars, string building, case statements and packages.

## External effects

- **console output** (allowed): Prints each perfect number found, using Put_Line.

Assessed on 2026-10-15 against page revision 412654 of the [task](https://rosettacode.org/wiki/Arithmetic/Rational) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
