# Fractal tree

**Candidate: proofs plausibly discharge automatically.** Text art satisfies the drawing requirement, and an explicit stack in a procedure avoids recursion while integer fixed-point rotation with ranged types and bounds guards keeps every check provable without annotations. Discharge depends on careful sizing of the stack and value ranges, so it is plausible rather than likely.

Position 814 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The tree is drawn iteratively in a procedure using an explicit fixed-capacity stack of branch records (start point, integer direction vector, level), popped in a while loop, with each branch's two children pushed after rotation by fixed-point sine and cosine constants and scaled by integer ratios. Each branch is rasterized by a for loop of fixed steps into a constrained 2D Character canvas, with bounds guards before every store. The canvas rows are then printed as Strings with Silver_IO.Put_Line. About 110 lines.

## Proof obligations to watch

- **overflow**: Branch vectors are rotated and scaled with integer fixed-point multiplications, which discharge only because every coordinate and vector component has a ranged subtype small enough that products fit in 32 bits, with scaled results clamped by guards.
- **range**: Branch endpoints can leave the canvas, so each plotted point is guarded by explicit bounds tests just before the array store, and the drawn picture simply omits off-canvas points as a documented limit.
- **index**: The explicit branch stack index is a loop-carried value in a while loop, so a guard before each push (depth bounded by the fixed level count and stack capacity) is needed rather than an invariant.
- **termination**: Recursion is replaced by an explicit stack in a procedure, which gets no termination check, and the line-drawing step uses a for loop over a fixed step count.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, records, for loops, while loops, procedures, string building and case statements.

## External effects

- **console output** (allowed): The tree is rendered as text art lines on standard output.

Assessed on 2026-10-15 against page revision 414948 of the [task](https://rosettacode.org/wiki/Fractal_tree) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
