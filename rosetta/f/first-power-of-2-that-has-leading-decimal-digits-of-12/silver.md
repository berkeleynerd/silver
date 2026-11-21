# First power of 2 that has leading decimal digits of 12

**Candidate: proofs plausibly discharge automatically.** Every check follows from the bounded mantissa subtype and the guards on the doubling and the counter, so no annotation is needed; the outlook is only plausible because correctness over about 1.9e8 truncating iterations depends on a documented precision limit.

Position 1504 in the [progression](../../progression.md#stage-29), in stage 29.

## Approach

A procedure Find(Prefix_Divisor, L, N, J, Found) keeps the power of two as an 18-digit normalized mantissa in a bounded Long_Long_Integer subtype, doubling it each step and dropping one digit when it reaches 10**18. A while loop in the procedure counts matches where the mantissa divided by Prefix_Divisor equals L, stopping at the N-th match or at a fixed exponent limit, and Main calls it for the five required (L, N) pairs and prints each result or a clear limit-exceeded message. About 70 lines.

## Proof obligations to watch

- **overflow**: The doubling of a mantissa subtype bounded to 10**17..10**18-1 stays under 2*10**18, which fits Long_Long_Integer, and the normalizing division by 10 is guarded by an explicit comparison.
- **range**: The exponent counter is a bounded subtype and is incremented only after a guard against the limit, with a visible not-found outcome when the limit is reached, so the 193-million-iteration loop needs no invariant.
- **other**: Keeping only the top 18 digits makes the result depend on truncation error that accumulates over about 1.9e8 doublings, so faithfulness to the expected values (such as 193060223) rests on a documented precision limit rather than a proof, and exact 58-million-digit big numbers are infeasible.

## Language surface recorded by this assessment

Integers, integer division, exponentiation, ranged subtypes, for loops, while loops, procedures, 'Image of scalars, string building and Boolean objects.

## External effects

- **console output** (allowed): Prints the five results with Put_Line.

Assessed on 2026-10-15 against page revision 413723 of the [task](https://rosettacode.org/wiki/First_power_of_2_that_has_leading_decimal_digits_of_12) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
