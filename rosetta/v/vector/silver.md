# Vector

**Candidate: proofs likely to discharge automatically.** All checks are range and division-by-zero obligations discharged by guards placed just before each operation, with no loops or recursion, so no annotation is needed; integer components stand in for floats to keep the proofs routine.

Position 608 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Represent a physical vector as a record of two components of a bounded integer subtype (scaled units, avoiding floating point), built from components directly. Add, Subtract, Scale and Divide are procedures returning the result vector plus an Ok flag, computing in a wider integer type and testing the range and nonzero divisor before narrowing; a Print procedure renders "(x, y)" using 'Image into a fixed bounded string and Put_Line. Main embeds example vectors, runs the four operations and prints each result, or prints a rejection message when a guard fails. About 80 lines.

## Proof obligations to watch

- **overflow**: Component add, subtract and multiply are done in a wider intermediate type and range-checked by an explicit guard before narrowing, with an overflow flag as the visible outcome.
- **division**: Scalar division is guarded by a nonzero test that reports a visible rejection, and truncating integer division of a bounded component cannot overflow.
- **length**: The pretty-print buffer is sized for the worst case of two signed 7-digit components plus punctuation, so concatenation lengths are static.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, records, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each pretty-printed result vector with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413116 of the [task](https://rosettacode.org/wiki/Vector) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
