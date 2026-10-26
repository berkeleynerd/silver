# Pell's equation

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded subtypes and explicit guards, but fixed-capacity big-number arithmetic carried through loops and the guards on loop-carried values make discharge depend on careful program shape rather than being routine.

Position 1380 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Compute the continued fraction of sqrt(n) with integer recurrences on small bounded subtypes, with guards before each multiply and divide, and carry the convergents h and k as fixed-capacity base-10 digit arrays (about 30 digits) updated by multiply-by-small plus add loops. Stop when the period ends (Z = 1 reached, repeating once if the period is odd) so no big squaring is needed, with an iteration cap that rejects; embed n = 61, 109, 181, 277 and print the digit arrays as text via Put_Line. About 170 lines.

## Proof obligations to watch

- **overflow**: The loop-carried continued-fraction values YY, Z and R are known only by type after the first iteration, so each is a bounded subtype and each product such as R*Z is guarded against that bound with a visible rejection outcome.
- **division**: Z is loop-carried so GNATprove cannot know it is nonzero, so an explicit guard on Z = 0 precedes each division and rejects.
- **overflow**: The solutions reach about 1.6e20, beyond 64 bits, so X and Y live in fixed-capacity digit arrays whose carry loops use bounded digit types and a capacity-exceeded guard that rejects.
- **termination**: The search loop is a while loop in a procedure, which gets no termination check, and an explicit iteration cap with rejection keeps it bounded and visible.
- **index**: Digit-array indexing in addition, multiply-by-small and printing uses for loops over the array's own range or guarded indexes.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, records, for loops, while loops, case statements, procedures, functions, string building, 'Image of scalars, big numbers, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): Prints one result line per n using Put_Line and Put.

Assessed on 2026-10-15 against page revision 413841 of the [task](https://rosettacode.org/wiki/Pell's_equation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
