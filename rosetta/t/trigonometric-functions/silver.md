# Trigonometric functions

**Candidate: proofs plausibly discharge automatically.** Nothing requires an annotation, a conflict or recursion since the task is a fixed set of float computations, but the proofs hinge on floating-point range and finiteness reasoning plus new float formatting output, so discharge is plausible rather than routine.

Position 1049 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Embed fixed example angles (45 degrees and pi/4 radians) as Float constants, convert degrees to radians with a constant factor, and compute sin, cos, tan and the inverses for each pair, either through admitted elementary-function library operations or bounded Taylor series in for loops over a fixed term count. Inverse calls use a fixed argument in range, guarded explicitly, and results are converted to degrees and radians then printed as formatted float text lines through a small output procedure. About 55 lines.

## Proof obligations to watch

- **floating point**: Float results and intermediate values must be proven finite, which works if the angle and series terms are bounded constants or ranged Float subtypes rather than loop-carried unbounded values.
- **division**: Tangent as sin/cos needs an explicit guard that cos is nonzero (or admitted library Tan preconditions), with a visible outcome when the guard fails.
- **range**: Inverse functions need the argument guarded into -1.0..1.0 (Arcsin, Arccos) before the call, with the fixed example value 0.5 making this static.
- **overflow**: If Taylor series replace library functions, loop-carried term and sum values must be bounded by a ranged subtype or a clamp, which GNATprove can accept but only with careful shape.

## Language surface recorded by this assessment

Floating point, floating-point images, ranged subtypes, procedures, functions, for loops and Put without a newline.

## External effects

- **console output** (allowed): Prints each radian/degree result pair as a text line.

Assessed on 2026-10-15 against page revision 414555 of the [task](https://rosettacode.org/wiki/Trigonometric_functions) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
