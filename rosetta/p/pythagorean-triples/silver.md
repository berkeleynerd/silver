# Pythagorean triples

**Candidate: proofs plausibly discharge automatically.** Every check follows from for-loop index ranges and a small bounded counter with a guard, so no annotation is needed, but the loop-carried counters and nested loops require careful program shape.

Position 170 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Embed the maximum perimeter 100 as a constant and enumerate a in 1..100, b in a+1..100, c in b+1..100 with for loops, counting a triple when a+b+c <= 100 and a*a+b*b = c*c. Primitiveness is decided by a nested for loop over divisors d in 2..a that tests whether d divides both a and b (using mod), avoiding a while-based gcd. Counters live in a bounded range subtype with a guarded increment that rejects on exhaustion, and the result is printed via 'Image concatenation with Put_Line; the extra-credit large limits are left out. About 45 lines.

## Proof obligations to watch

- **overflow**: Counters are loop-carried, so they get a declared range type and an explicit guard before each increment that calls Reject, which never fires for limit 100 but keeps the outcome visible.
- **overflow**: a*a+b*b is bounded by the loop index ranges 1..100, so the products and sum fit in Integer and discharge from types.
- **termination**: Only for loops are used, so every loop terminates by itself even if the work sits in a function.
- **other**: Cubic enumeration of a, b, c up to 100 is roughly 170,000 iterations, which is fine at run time and adds no proof burden since no loop-carried fact is needed beyond the counter guard.

## Language surface beyond today's Silver

Integers, ranged subtypes, for loops, 'Image of scalars, string building, Boolean objects and integer division.

## External effects

- **console output** (allowed): Prints the triple count and primitive count with Put_Line.

Assessed on 2026-10-15 against page revision 413868 of the [task](https://rosettacode.org/wiki/Pythagorean_triples) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
