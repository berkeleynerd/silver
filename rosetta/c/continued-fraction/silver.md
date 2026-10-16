# Continued fraction

**Candidate: proofs plausibly discharge automatically.** The task is a fixed-step reverse for-loop with positive coefficients, so termination is trivial and checks follow from ranged subtypes. The nonroutine part is bounding the float accumulator so the division and conversions discharge, and Silver lacking float formatting.

Position 1061 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Write one procedure per series (or a single procedure with a selector) that runs a for-loop in reverse over 1 .. Steps with constant step counts, computing the coefficients A and B from N in ranged integer subtypes and converting them to a bounded float subtype. The accumulator Fraction is declared in a subtype 0.0 .. 1.0 (or 0.0 .. 2.0) and the denominator A + Fraction is guarded to be at least 1.0 before each division. Results are printed with a library float-to-text operation or by scaling to an integer and emitting 14 decimal digits, using Put_Line. About 70 lines.

## Proof obligations to watch

- **floating point**: The backward loop Fraction := B/(A+Fraction) divides by a loop-carried float, so the program must keep Fraction in a bounded float subtype (all coefficients are positive so A+Fraction >= 1) and guard the denominator before dividing, which provers handle only with range guards.
- **overflow**: Pi's B(N) = (2N-1)**2 at N up to 10000 is about 4e8, so N is a ranged subtype capping steps and B is computed in a 64-bit integer range so the product cannot overflow.
- **range**: Float conversion of the integer coefficients and the Fraction result must stay inside the declared float subtype range, which needs explicit bounds such as 0.0 .. 1.0 for the tail since each tail value is at most B/A.
- **other**: Printing a float needs an admitted float-to-text library operation (or integer scaling to fixed decimals via integer-division digit emission), since Silver has no float formatting yet.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, floating point, floating-point images, arrays, for loops, procedures, functions, Put without a newline, 'Image of scalars, string building, string indexing, characters and while loops.

## External effects

- **console output** (allowed): Prints the three approximations, one per line.

Assessed on 2026-10-15 against page revision 415071 of the [task](https://rosettacode.org/wiki/Continued_fraction) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
