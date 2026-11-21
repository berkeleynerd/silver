# Arithmetic derivative

**Candidate: proofs plausibly discharge automatically.** All values for -99..100 are tiny, so types and a guard on the accumulator should discharge every check, but the carried accumulator and nested loops need careful program shape, hence plausible rather than likely.

Position 232 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A procedure computes D(m) for m in 1..100 by trial division with a for loop over candidates 2..100 and an inner while loop stripping each factor, adding m/p per factor occurrence (D(m) = m * sum of e/p); negative inputs use -D(-n) and D(0)=D(1)=0. The main loop runs i from -99 to 100, calls the procedure, and prints each result as text built from 'Image with Put_Line. Values stay within small declared subtypes, with explicit guards before additions. The optional stretch task (10^20 exceeds 64 bits) is left out. About 50 lines.

## Proof obligations to watch

- **overflow**: The loop-carried derivative accumulator has no invariant, so each addition is guarded by a bound test that leads to a visible Reject path rather than altering results.
- **range**: The remaining-cofactor variable is a subtype 1..100 and is only divided by a for-loop index of at least 2, so the quotient stays in range from types alone.
- **termination**: The factor-stripping while loop sits in a procedure, which gets no termination check, and the outer candidate loop is a for loop.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, while loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints D(n) for each n from -99 to 100, one line per value.

Assessed on 2026-10-15 against page revision 414061 of the [task](https://rosettacode.org/wiki/Arithmetic_derivative) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
