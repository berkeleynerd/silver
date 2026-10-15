# Convex hull

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded by a declared coordinate subtype and all array accesses are protected by guards just before use, but several loop-carried stack indices need careful guard placement, so discharge is plausible rather than certain.

Position 627 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

The 20 example points are embedded as a constant array of a Point record with coordinates in a small integer subtype, copied into a working array and sorted by X then Y with an insertion sort procedure. Andrew's monotone chain builds the lower and then upper hull on a fixed-capacity array used as a stack, with a Cross function and guarded while loops that pop while Top >= 2 and the turn is not counter-clockwise. The hull is printed one point per line with Put_Line (or a bounded line buffer), rejecting visibly if the stack capacity guard ever fails. About 110 lines.

## Proof obligations to watch

- **overflow**: The cross product multiplies coordinate differences, which is discharged by declaring coordinates as a small subtype (about -100..100) so every product and difference fits in Integer.
- **index**: The hull stack top is a loop-carried counter, so every push is preceded by a guard comparing it to the capacity (2 * point count) with a specified reject outcome, and every Top - 1 or Top - 2 access is preceded by a Top >= 2 test.
- **index**: The insertion sort's shifting while loop is in a procedure and guards its index with J > 1 before each access, so no invariant is needed.
- **length**: The output line is assembled with 'Image of each coordinate into a bounded buffer whose size covers the worst case, with a guard before each append.
- **termination**: All while loops live in procedures, which get no termination check, and the cross product is a plain non-recursive function.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, records, for loops, while loops, procedures, functions, Boolean objects, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The hull points are printed as text lines.

Assessed on 2026-10-15 against page revision 414917 of the [task](https://rosettacode.org/wiki/Convex_hull) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
