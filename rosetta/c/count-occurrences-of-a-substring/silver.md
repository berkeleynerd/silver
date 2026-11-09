# Count occurrences of a substring

**Candidate: proofs likely to discharge automatically.** All checks are index and range checks on a bounded left-to-right scan guarded by the window-fits test, and since the loop sits in a procedure no termination check is needed, so discharge should be routine.

Position 502 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

A procedure Count_Substring takes a text String, a pattern String and an out Natural count, and scans left to right with a while loop (allowed in procedures) that keeps a Natural position, comparing the pattern characters by index in an inner for loop with an explicit guard that the window fits and the pattern is non-empty (an empty pattern gives count 0 as a specified outcome). On a full match it increments the count and jumps by the pattern length, otherwise it advances by one; Main calls it on the two embedded examples and prints the results with Integer'Image through Put_Line. About 45 lines.

## Proof obligations to watch

- **index**: Each window comparison index (Pos + K - 1) is guarded by an explicit Pos + Pat'Length - 1 <= Text'Length loop condition inside a procedure with fixed-length String parameters, so it discharges.
- **overflow**: The match counter and position are subtypes bounded by the fixed text length, and the count increment is guarded by the position bound, so the increment does not overflow.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, string indexing, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The program prints the two example counts, 3 and 2, as text lines.

Assessed on 2026-10-15 against page revision 415383 of the [task](https://rosettacode.org/wiki/Count_occurrences_of_a_substring) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
