# Roots of a function

**Candidate: proofs likely to discharge automatically.** The task is satisfied by a fixed-step scan in scaled integer arithmetic, avoiding floating point, so every check follows from the subtype bounds of the for loop index and carries no loop-carried values.

Position 337 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Represent x in thousandths as an integer subtype -1000..3000 and compute a scaled f(x) = x^3 - 3000x^2 + 2000000x in a 64-bit integer function (cubic in milli-units, scaled by 10^9 consistently). A for loop scans each step from the start, reporting "exact root" when the value is zero and "approximate root between x and x+step" when the sign changes between adjacent samples, printing x as integer part and three-digit fraction via / and mod and 'Image. About 55 lines.

## Proof obligations to watch

- **overflow**: X*X*X on a subtype bounded to -1000..3000 and held in a 64-bit integer stays near 2.7E10, so the nonlinear products are bounded by types and discharge.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, functions, for loops, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Root reports (exact or approximate, with the x value) are printed line by line.

Assessed on 2026-10-15 against page revision 413884 of the [task](https://rosettacode.org/wiki/Roots_of_a_function) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
