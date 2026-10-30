# Zig-zag matrix

**Candidate: proofs plausibly discharge automatically.** All checks come from the 1..5 index subtypes, the 0..24 element subtype and guards before each cursor step, with no recursion or functions with while loops, but the loop-carried cursors need careful guard placement. The program is plausible rather than likely for that reason.

Position 901 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Use a constant Size of 5 and a 5 by 5 array of a 0..24 subtype, filled in a Main procedure by a for loop over the elements 1..24 that moves guarded row and column cursors of subtype 1..5 along the anti-diagonals. Every cursor move is preceded by a bound test so each index stays in range. Nested for loops over the array's own ranges then print each row with Integer'Image and Put, followed by a line terminator. About 45 lines.

## Proof obligations to watch

- **index**: The carried row and column cursors are known only by their 1..5 subtype after the first iteration, so every step such as I+2 or J-1 needs an explicit guard just before use, with an unreachable fallback that leaves the cursor unchanged.
- **overflow**: The counter is a for-loop index bounded by 24 and stored in a 0..24 element subtype, so the store discharges from declared ranges.
- **range**: Walking anti-diagonals with nested for loops and computing the cell from the diagonal and offset avoids loop-carried state but needs range guards on the computed row and column.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, 'Image of scalars, Put without a newline, procedures and conditional expressions.

## External effects

- **console output** (allowed): The 5 by 5 array is printed as rows of numbers on standard output.

Assessed on 2026-10-15 against page revision 414599 of the [task](https://rosettacode.org/wiki/Zig-zag_matrix) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
