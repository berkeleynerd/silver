# Continued fraction convergents

**Candidate: proofs plausibly discharge automatically.** Everything is integer arithmetic in procedures with for loops or procedure-only while loops, and the loop-carried overflow and zero-division risks are handled by visible guards, so no annotation is needed, but it takes careful program shape.

Position 939 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Embed the five test cases as constants; rationals use a Euclid while loop in a procedure that stores partial quotients in a fixed array, and quadratic numbers are normalised to (P+sqrt(D))/Q and expanded by the integer recurrence a=(P+isqrt D)/Q, P'=aQ-P, Q'=(D-P'^2)/Q for k=8 terms using an integer-only square root. Convergents h=a*h1+h2 and k=a*k1+k2 are computed in Long_Long_Integer with explicit bound guards before each multiply-add, then formatted with 'Image into a bounded line buffer and printed with Put_Line. About 150 lines.

## Proof obligations to watch

- **overflow**: Convergent numerators and denominators, and the quadratic recurrence terms P, Q and P*P, are loop-carried, so each update is preceded by a guard against a fixed bound (for example 10**9 in 64-bit Long_Long_Integer), and exceeding it ends the sequence with a visible 'limit reached' line.
- **division**: The quadratic recurrence divides by the loop-carried Q, so the loop tests Q /= 0 immediately before each division and reports a visible failure otherwise.
- **termination**: The Euclid loop and the integer square root are while loops, so they live in procedures (which get no termination check), and the convergent loop is a for loop over k.
- **range**: Partial quotients come from division and are stored in a bounded array indexed by a for-loop counter, with the term count capped at a declared maximum such as 16.
- **length**: Output text is assembled in a fixed-size bounded buffer with explicit remaining-capacity guards before each append, sized well above the longest line printed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions, 'Image of scalars, string building, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints each test label and its list of convergents as text lines.

Assessed on 2026-10-15 against page revision 394520 of the [task](https://rosettacode.org/wiki/Continued_fraction_convergents) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
