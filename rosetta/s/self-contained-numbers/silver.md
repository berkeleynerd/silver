# Self-contained numbers

**Candidate: proofs plausibly discharge automatically.** Every check is tied to a type range or a guard placed directly before the operation, and the Collatz loops sit in procedures so no termination proof is demanded, but the loop-carried hailstone value needs a careful ceiling guard and the search bound (about 1.1 million starts) must be a stated resource limit.

Position 917 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Declare a ranged 64-bit subtype for hailstone values with a documented ceiling and an array of 7 results; a for loop over k in a static range sets i = 2*k+1, and an inner while loop in a procedure steps j (halve if even, else guard against the ceiling then 3*j+1), testing j mod i = 0 after each step and recording i with a guarded count. After the search, each found number is printed via integer image, and if fewer than 7 were found or the ceiling was hit a specified message is printed instead. About 70 lines.

## Proof obligations to watch

- **overflow**: The hailstone value 3*j+1 is a loop-carried 64-bit value, so the program tests j against a documented ceiling (for example 10**17) immediately before the step and ends the search with a visible 'limit exceeded' message otherwise, which also covers the task's unbounded-search wish only up to that stated resource limit.
- **division**: j mod i is safe because i is derived as 2*k+1 from a for-loop index over a static range, so i is at least 1 by its subtype and no guard is needed.
- **index**: The result array of 7 entries is written only after a guard that the count is below 7, and the outer loop stops once 7 are found.
- **termination**: Collatz termination is unprovable but all while loops live in a procedure, which gets no termination check, and the outer loop is a bounded for loop.
- **range**: Converting the loop index to the odd start value and the Image-based output buffer need explicit subtype ranges sized for 64-bit values (at most 20 digits), which is routine if the subtypes are declared tightly.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, string building and conditional expressions.

## External effects

- **console output** (allowed): Prints the seven self-contained numbers (or a visible overflow-limit message) with Put_Line.

Assessed on 2026-10-15 against page revision 411280 of the [task](https://rosettacode.org/wiki/Self-contained_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
