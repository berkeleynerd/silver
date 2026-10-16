# Law of cosines - triples

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded by the 1..13 side subtype and the loops are plain for loops, so only the loop-carried counter needs a visible guard; the result is plausible rather than certain because of that guard and the integer-to-text output.

Position 48 in the [progression](../../progression.md#stage-3), in stage 3.

## Approach

Declare a Side subtype 1..13 and a small bounded count subtype, then run three nested for loops (A in 1..13, B in 1..A, C in 1..13) once per angle (60, 90, 120) in a helper procedure or three loop blocks, testing A*A + B*B -/+ A*B = C*C. Each hit prints the triple with 'Image concatenation and increments a guarded counter, and the count is printed after each angle; the optional 1..10_000 extra credit is omitted. About 60 lines.

## Proof obligations to watch

- **overflow**: The per-angle counter is carried through nested loops and, with no invariant, its increment is proven safe only by a guard against its subtype maximum that rejects visibly, which is never reached for sides 1..13.
- **range**: Computing A*A + B*B +/- A*B in an Integer-based expression is bounded by the side subtype 1..13 so it cannot overflow and the C*C comparison needs no guard.

## Language surface recorded by this assessment

Integers, ranged subtypes, for loops, 'Image of scalars and procedures.

## External effects

- **console output** (allowed): Prints each triple and the per-angle counts with Put_Line.

Assessed on 2026-10-15 against page revision 414304 of the [task](https://rosettacode.org/wiki/Law_of_cosines_-_triples) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
