# CORDIC

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded scaled-integer work with for loops and guards before each update, so the checks follow from types and guards, but the carried x, y and z values need careful subtype and guard shaping and the decimal formatting adds string-building effort.

Position 400 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Angles and arctangent constants are embedded as integers scaled by 10^9 in a constant array, and a procedure runs a fixed 24-iteration for loop doing the rotate step on x, y, z subtype-bounded Long_Long_Integer values using division by powers of two in place of shifts. Inputs -9, 0, 1.5 and 6 are first reduced into [-pi/2, pi/2] by a guarded loop that tracks a sign flip, then the scaled cosine is converted to a decimal string by integer division and 'Image into a bounded buffer and printed with Put_Line. About 110 lines.

## Proof obligations to watch

- **overflow**: The loop-carried x, y and z values are known only by their subtype range after the first iteration, so each update is computed in Long_Long_Integer from a wide-margin subtype and guarded with an explicit range test that rejects out-of-range results.
- **range**: Range reduction of -9 and 6 into [-pi/2, pi/2] uses a fixed-point constant for pi and a guarded for-loop or while-loop in a procedure that subtracts pi, with the angle subtype bounding every intermediate.
- **floating point**: Scaled integer fixed-point arithmetic avoids floating-point provers entirely, at the cost of the shifts being written as division by a power of two from a table.
- **termination**: Iterations use a for loop over a constant count, and any range-reduction while loop lives in a procedure so no variant is required.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the cosine results for the four angles.

Assessed on 2026-10-15 against page revision 409004 of the [task](https://rosettacode.org/wiki/CORDIC) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
