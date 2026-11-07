# Find if a point is within a triangle

**Candidate: proofs likely to discharge automatically.** Everything is loop-free integer arithmetic on bounded coordinates, so every overflow check discharges from the subtype ranges alone. The only deviation from the task's real coordinates is a documented integer-coordinate bound, which the Oracle permits as an explicit resource limit.

Position 589 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Points and triangles are records of range-bounded integer coordinates, and a non-recursive Boolean function computes the three edge cross-product signs, treating the point as inside when the signs do not conflict (boundary counts as inside). Main holds the embedded example triangles and points, calls the function in straight-line code and prints each result with Put_Line, with no loops needed. About 55 lines.

## Proof obligations to watch

- **overflow**: Coordinates are a subtype bounded to a documented range such as -1000..1000, so the cross-product terms stay far below the Integer limits and the checks follow from types.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, functions, records, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the verdict for each embedded point and triangle with Put_Line.

Assessed on 2026-10-15 against page revision 415479 of the [task](https://rosettacode.org/wiki/Find_if_a_point_is_within_a_triangle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
