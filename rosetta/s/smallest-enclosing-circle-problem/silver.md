# Smallest enclosing circle problem

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded integer subtypes and a determinant guard, but nonlinear products and the float formatting of the radius need careful range shaping, and a brute-force search avoids recursion and invariants.

Position 1114 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Points are integer pairs in a fixed-capacity array with a count, and the program tries every pair-diameter circle and every non-collinear triple circumcircle by brute force, choosing the containing circle with the smallest squared radius kept as an exact rational (numerator over denominator) so containment tests use integer cross-multiplication. Embedded test sets (the two from the task) are processed through one procedure that loops over the arrays and prints the centre and radius. The n-dimensional requirement is met by the 2D case only, with the point count and coordinate range documented as limits. About 170 lines.

## Proof obligations to watch

- **overflow**: Circumcentre numerators and squared distance comparisons are nonlinear, so coordinates are limited to -100..100 in a documented subtype so every product fits in 64-bit integers and the provers can bound them.
- **division**: The circumcircle determinant is tested against zero in an explicit guard so collinear triples are skipped before any division.
- **floating point**: Floating point is confined to the final output, where the radius is a Sqrt of a bounded non-negative value and the centre is a quotient of bounded integers, so no overflow check is left open.
- **termination**: Only for loops over constant array ranges are used, so no variant is required.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, procedures, functions, 'Image of scalars, floating-point images, floating point, Put without a newline, string building and conditional expressions.

## External effects

- **console output** (allowed): Prints each test point set with the resulting circle centre and radius.

Assessed on 2026-10-15 against page revision 414472 of the [task](https://rosettacode.org/wiki/Smallest_enclosing_circle_problem) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
