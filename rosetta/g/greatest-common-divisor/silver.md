# Greatest common divisor

**Candidate: proofs likely to discharge automatically.** Euclid's algorithm needs only Natural-typed loop variables, and since T mod N with N nonzero yields a value below N, every range and division check follows from types and the loop guard without an invariant. Putting the loop in a procedure avoids the function termination obligation.

Position 187 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A procedure Gcd takes two Natural values and returns a Natural out parameter, running Euclid's algorithm with a while loop on Natural-typed copies M and N, where N is nonzero inside the loop body. Main calls it on embedded pairs such as (100,5), (5,100) and (7,23) and prints each result with Integer'Image concatenated into a bounded String line. About 28 lines.

## Proof obligations to watch

- **termination**: The Euclid while loop is in a procedure, which gets no termination check, so no variant is needed.
- **division**: The loop condition N /= 0 immediately guards the mod, so the division check discharges.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, while loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the GCD results for embedded example pairs with Put_Line.

Assessed on 2026-10-15 against page revision 415534 of the [task](https://rosettacode.org/wiki/Greatest_common_divisor) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
