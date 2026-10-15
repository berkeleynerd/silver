# OpenGL/Utah teapot

**Excluded from Silver: graphics.** Only the graphics effect goes beyond what the Oracle allows today, and it is an effect, not a conflict. The patch data and evaluation loops use static bounds, but floating-point overflow checks discharge only if coordinates use ranged subtypes and sums are written without loop-carried accumulators, so the outlook is plausible.

## Approach

The standard 306 control points and 32 bicubic patches (16 indices each) are embedded as constant arrays with ranged float and index subtypes. Nested for loops over the patches and a fixed tessellation grid evaluate each surface point with explicit straight-line Bernstein sums, and a procedure sends the resulting wireframe lines to the admitted OpenGL operations to draw one fixed rotated view. Rotation and animation are left out because they are optional. About 220 lines.

## Proof obligations to watch

- **floating point**: Bezier evaluation multiplies Bernstein weights in [0,1] by control coordinates declared in a subtype such as -4.0 .. 4.0, and writing each surface point as straight-line sums of 4-term rows avoids loop-carried float accumulators, so the overflow and range checks stay within what the provers can bound.
- **index**: Patch index entries are declared as a vertex-index subtype matching the control-point array's range, so looking up control points by stored indices discharges from the types.
- **range**: The parameter u = Float(K) / Float(N) for a for-loop index K in 0 .. N with static positive N stays in [0,1], which provers can establish from the static bounds before passing it to the basis functions.

## Language surface beyond today's Silver

Floating point, ranged subtypes, integers, integer division, arrays, multidimensional arrays, records, for loops, procedures and functions.

## External effects

- **graphics** (not allowed): The task requires rendering the teapot through the OpenGL library, so the program needs an admitted OpenGL-style operation set to open a window, set up the view and draw line or triangle primitives.

Assessed on 2026-10-15 against page revision 393306 of the [task](https://rosettacode.org/wiki/OpenGL/Utah_teapot) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
