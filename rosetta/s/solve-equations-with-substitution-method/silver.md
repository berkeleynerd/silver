# Solve equations with substitution method

**Candidate: proofs likely to discharge automatically.** The task is a fixed two-equation linear solve done as straight-line integer arithmetic, so all checks follow from bounded types and one divisor guard. No loops, recursion or annotations are needed.

Position 127 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Embed the two equations as named integer constants of a small ranged subtype, solve the first for y, substitute into the second to get x times (a2 - b2*a1) equals r2 - b2*r1, and guard the divisor for zero and the division for exactness with mod. Then compute y from the first equation and print both values with 'Image, with a visible message when there is no unique integer solution. The control flow is straight-line code with a few ifs and no loops. About 35 lines.

## Proof obligations to watch

- **division**: The divisor a2 - b2*a1 is tested against zero by an explicit if just before the division, with a visible 'no unique solution' output otherwise.
- **overflow**: Coefficients are declared as a small ranged subtype (about -1000..1000), so every product and difference fits in Integer and the checks follow from types.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the solved values of x and y as text lines.

Assessed on 2026-10-15 against page revision 407798 of the [task](https://rosettacode.org/wiki/Solve_equations_with_substitution_method) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
