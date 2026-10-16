# WebGL rotating F

**Excluded from Silver: graphics, GUI, clock.** The task requires a live rotating 3D F drawn through WebGL or OpenGL ES 2.0, so it needs graphics, a window and animation timing. Those are external effects Silver lacks, not conflicts with any Oracle rule. A bounded-array, iteration-based Ada solution calling admitted GL bindings is conceivable.

## Language surface recorded by this assessment

Floating point, arrays, loops, subprograms and records.

## External effects

- **graphics** (not allowed): The task requires WebGL or OpenGL ES 2.0 rendering of a rotating 3D F shape, which means drawing to a display.
- **GUI** (not allowed): The task needs a window or canvas to show the animation. A WebGL page or GLUT window provides it.
- **clock** (not allowed): The F rotates continuously, so frame timing or elapsed time drives the animation.

Assessed on 2026-10-15 against page revision 408806 of the [task](https://rosettacode.org/wiki/WebGL_rotating_F) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
