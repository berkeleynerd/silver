# Line circle intersection

**Candidate: proofs plausibly discharge automatically.** The task is closed-form geometry with no loops or recursion, so the only non-routine checks are float range, sqrt domain and division, which tightly ranged subtypes and explicit guards should discharge, though floating-point keeps it at plausible rather than likely.

Position 1083 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Use a ranged Float subtype for coordinates, a Point record, and a procedure Intersect(P1, P2, Center, Radius, Is_Segment) that solves the parametric quadratic with t along P1 to P2, rejecting coincident points and negative discriminants with visible outcomes, then keeping t within 0..1 for segments. The main procedure runs the task's embedded examples, including the stretch cases, by calling Intersect, which prints each result via Put_Line with text built from float images; there are no loop-carried values. About 110 lines.

## Proof obligations to watch

- **floating point**: Intermediate products and the discriminant must be proven finite and within Float range, which works only if coordinates and radius are declared as tightly ranged subtypes such as -1000.0 .. 1000.0.
- **division**: The quadratic coefficient is the squared length of the direction vector, so the program guards with an explicit check that the two defining points differ and reports a degenerate line otherwise.
- **range**: Square root is called only in a branch guarded by discriminant >= 0.0, and segment membership is a plain comparison of the parameter t against 0.0 and 1.0.
- **length**: Formatting float results into text needs a bounded buffer sized for the worst-case image, which depends on how float-image is admitted in the library.

## Language surface recorded by this assessment

Floating point, ranged subtypes, records, Boolean objects, procedures, functions, floating-point images and string building.

## External effects

- **console output** (allowed): The program prints the intersection points for the embedded example lines, segments and circles.

Assessed on 2026-10-15 against page revision 400573 of the [task](https://rosettacode.org/wiki/Line_circle_intersection) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
