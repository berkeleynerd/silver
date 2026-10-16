# Arithmetic/Complex

**Candidate: proofs plausibly discharge automatically.** The operations are straight-line floating-point expressions over range-bounded inputs with one explicit zero-denominator guard, so they should prove without annotations, but float arithmetic and float-to-text formatting make it depend on careful range shaping.

Position 1075 in the [progression](../../../progression.md#stage-19), in stage 19.

## Approach

Define a bounded Real subtype and a Complex record of two Float components, with non-recursive functions Add, Mul, Neg, Inv and Conj, and embed two example values such as 1+1i and a fixed pi-polar-like pair given as Cartesian constants. A main procedure applies each operation, guards Inv against a near-zero denominator with a visible rejection line, and prints each result via a bounded image of the components using Put_Line. About 90 lines.

## Proof obligations to watch

- **floating point**: Add, multiply, negate and conjugate on components bounded by a declared range subtype cannot overflow Float, which the provers can show from the range bounds alone.
- **division**: Inversion divides by Re*Re+Im*Im, so the program guards that the operand magnitudes are at least a small declared threshold (otherwise it prints a specified 'cannot invert' line) before the division.
- **range**: Results are stored in wider-range or plain Float components so the range checks on record construction follow from the bounded input domain rather than needing a postcondition.
- **overflow**: Nonlinear products and the reciprocal of a guarded denominator must be bounded by the range subtype and the threshold, which is likely but needs the guard shaped so the solvers can see the bounds.

## Language surface beyond today's Silver

Floating point, floating-point images, ranged subtypes, records, functions, procedures, integers, Put without a newline, string building, conditional expressions and Boolean objects.

## External effects

- **console output** (allowed): Prints the result of each tested operation as lines of text.

Assessed on 2026-10-15 against page revision 412650 of the [task](https://rosettacode.org/wiki/Arithmetic/Complex) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
