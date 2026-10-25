# Ramer-Douglas-Peucker line simplification

**Candidate: proofs plausibly discharge automatically.** The task is small and fixed-size, and replacing recursion with a bounded explicit stack plus scaled-integer squared distances avoids floating point, sqrt and function termination, leaving only guarded stack indexing and bounded arithmetic. Discharge depends on careful shape (loop-carried stack top and distance maximum) but needs no annotations.

Position 259 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Store the ten points as two constant arrays of integer tenths, a Boolean keep array, and an explicit stack of (start, end) index pairs replacing recursion. A while loop in a procedure pops a range, a for loop finds the point with the largest squared cross-product distance, and if it exceeds the squared threshold (scaled) it marks that point and pushes both sub-ranges under a capacity guard; finally kept points are printed as decimal text such as (2, -0.1). About 90 lines.

## Proof obligations to watch

- **overflow**: Coordinates are held as tenths in a small ranged subtype and the squared cross product and squared threshold comparison are bounded by those ranges, so no square root or floating point is needed and products fit in Integer.
- **index**: The explicit range stack is a fixed array with a loop-carried top counter, so each push is guarded by a check that top is below capacity (ten points need at most ten entries) with a visible rejection otherwise.
- **termination**: The stack-driven while loop lives in a procedure, which gets no termination check, and recursion is replaced by this explicit stack.
- **length**: Formatting tenths as decimal text builds strings in a bounded buffer whose size covers the largest value, with the sign and fractional digit placed under guards.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The remaining points are printed to standard output.

Assessed on 2026-10-15 against page revision 414426 of the [task](https://rosettacode.org/wiki/Ramer-Douglas-Peucker_line_simplification) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
