# Find the intersection of two lines

**Candidate: proofs likely to discharge automatically.** All arithmetic is bounded integer arithmetic with a single explicit zero-determinant guard before the only division, so every check follows from types and a guard; the Ada solution's Float and exception are replaced by exact integers and a visible message.

Position 144 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Represent the four points as constants of a bounded Coordinate subtype and solve the two-line system in exact integer arithmetic with the determinant formula, avoiding floating point. If the determinant is zero print that the lines are parallel or coincident; otherwise compute the numerators and print x and y as integers when the remainder is zero (5 and 5 for the given data) or as num/den fractions otherwise. About 45 lines.

## Proof obligations to watch

- **division**: The determinant is tested against zero in an if just before the division, with a visible 'no intersection' output otherwise.
- **overflow**: Coordinates are a declared subtype of -1000..1000 so the cross-product terms stay far inside Integer.
- **length**: The output line is concatenated from short Integer'Image results whose maximum length is bounded by the coordinate subtype and fits the target buffer.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, 'Image of scalars, string building and procedures.

## External effects

- **console output** (allowed): Prints the intersection point (or a no-intersection message) with Put_Line.

Assessed on 2026-10-15 against page revision 413182 of the [task](https://rosettacode.org/wiki/Find_the_intersection_of_two_lines) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
