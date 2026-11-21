# Quickhull

**Candidate: proofs plausibly discharge automatically.** The recursive algorithm can be turned into an iterative worklist in a procedure using bounded arrays and exact integer visibility tests, so only the final area sum uses floating point on bounded values. It is plausible rather than likely because many loop-carried indices and counters each need a guard and the program is large.

Position 1034 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Store up to a fixed number of points as integer coordinate triples in a bounded range, and faces as arrays of three point indices with a deleted flag and per-face outside-point lists; the initial tetrahedron comes from extreme points found by for loops, rejecting inputs with fewer than four non-coplanar points. An iterative procedure with a bounded while loop pulls a face with outside points, picks the farthest point by exact integer dot product with the face normal, marks visible faces deleted, finds horizon edges by scanning edge pairs of deleted faces against kept faces, and appends new faces, with a capacity guard before every append. Finally a for loop sums half the Float square root of each live face's integer cross-product magnitude and prints it. About 260 lines.

## Proof obligations to watch

- **floating point**: Cross-product magnitudes and the square root must be proved free of overflow and negative sqrt arguments, which holds if coordinates are bounded integer-valued subtypes and the sum of squares is computed in a bounded range type.
- **index**: Face, point and horizon-edge indices are loop-carried in a worklist loop, so each use needs an explicit capacity guard just before it, with overflow of capacity leading to a reported rejection.
- **overflow**: Face and queue counters grow inside while loops without invariants, so each increment is guarded against its subtype maximum, with the capacity limit documented.
- **termination**: The face-processing while loop lives in a procedure so it needs no variant, but termination of the result is not proved and the loop is bounded by a counter of processed steps to guarantee it ends.
- **division**: Point-to-plane distance divides by the normal magnitude, avoided by comparing the unnormalized integer dot product and rejecting degenerate (collinear or coplanar) inputs before any division.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, floating point, arrays, records, for loops, while loops, procedures, functions, floating-point images, 'Image of scalars, Put without a newline and integer division.

## External effects

- **console output** (allowed): The surface area is printed as text, and degenerate input is reported with a message.

Assessed on 2026-10-15 against page revision 414421 of the [task](https://rosettacode.org/wiki/Quickhull) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
