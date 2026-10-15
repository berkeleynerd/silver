# Sturm sequence

**Candidate: proofs plausibly discharge automatically.** The program needs only arrays, records, for loops and procedures, and it uses no recursion or annotations. Its outlook is plausible rather than likely because Long_Float overflow and division checks on values carried through Horner evaluation and polynomial division discharge only if magnitude guards are placed carefully before each operation.

Position 1116 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Each polynomial is a record holding a degree in a ranged subtype and a fixed-capacity Long_Float coefficient array. The example polynomials are embedded as an array aggregate. For each one, a procedure builds the Sturm sequence into a fixed array of such records using a for loop bounded by the degree, with negated remainders from guarded long division. Roots are isolated over a Cauchy bound using an explicit worklist of intervals: Sturm sign-variation counts split intervals until each holds one root, and then a fixed-count for-loop bisection refines it. Magnitude guards placed before every floating-point operation, and capacity guards before every array write, lead to a printed rejection of that polynomial. About 220 lines.

## Proof obligations to watch

- **floating point**: Horner evaluation, polynomial long division and the negated remainders carry Long_Float values through loops, so each multiply and add needs a guard just before it that bounds the operands (for example |acc| and |x| at most 1.0E100), with any breach reported as an explicit 'numeric limit exceeded' outcome for that polynomial.
- **division**: Dividing by a divisor's leading coefficient, and making the polynomial monic, is guarded by trimming coefficients whose magnitude falls below a small threshold, so the divisor is provably nonzero and the quotient cannot overflow.
- **index**: Coefficient arrays, the Sturm sequence array and the explicit interval worklist that replaces recursive isolation all have fixed capacity, and each write is guarded by a count check before it that leads to a reported capacity failure.
- **overflow**: The sign-variation counter and the root count are bounded by the sequence length and the degree, so they rely on declared ranged subtypes plus a guard before each increment.
- **termination**: Interval isolation runs in a procedure as a for loop capped at a fixed number of worklist steps, and bisection uses a for loop with a fixed iteration cap, so there is no while loop or recursion inside a function.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, floating point, floating-point images, arrays, records, 'Image of scalars, for loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints each example polynomial followed by its isolated real roots, or a message that it has none or that a numeric limit was exceeded.

Assessed on 2026-10-15 against page revision 408668 of the [task](https://rosettacode.org/wiki/Sturm_sequence) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
