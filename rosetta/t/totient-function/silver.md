# Totient function

**Candidate: proofs plausibly discharge automatically.** All checks come from subtype ranges, a static for-loop bound and guards, and the only while loop sits in a procedure, so no annotation is needed; the loop-carried Tot and counter arithmetic need careful range typing and guards, which makes discharge plausible rather than certain.

Position 248 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A procedure Totient (N : in Positive_Limit; Phi : out Natural_Limit) copies N into N2 and Tot, runs for I in 2 .. 316 with an if I * I <= N2 guard and an inner while N2 mod I = 0 loop dividing out the factor and setting Tot := Tot - Tot / I, then adjusts for a leftover prime factor N2 > 1. Main loops N in 1 .. 100000 with embedded constants, calling the procedure, counting primes where Phi = N - 1 under a bounded-counter guard, printing the first 25 rows with 'Image-built lines, and printing the count at 100, 1000, 10000 and 100000. About 70 lines.

## Proof obligations to watch

- **range**: The loop-carried Tot in Tot - Tot / I (declared 0..100000) is unknown after the first iteration, so the program relies on the type range plus I >= 2 to let provers show the difference stays in range, which is nonlinear division reasoning.
- **overflow**: The prime counter incremented across up to 100000 iterations needs a guard such as Count < 100000 with a visible Reject outcome, since without an invariant its bound is otherwise unknown.
- **overflow**: I * I is avoided by looping I over the static range 2 .. 316 so that I * I <= 99856 is safe in Integer.
- **termination**: The inner while loop dividing N2 by I exists only in a procedure (totient as an out-parameter procedure), so no termination check is generated.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, procedures, for loops, while loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the 25 index/totient/primality lines and the prime counts up to 100, 1,000, 10,000 and 100,000 with Put_Line.

Assessed on 2026-10-15 against page revision 415248 of the [task](https://rosettacode.org/wiki/Totient_function) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
