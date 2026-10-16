# Next highest int from digits

**Candidate: proofs likely to discharge automatically.** Every index comes from a for-loop variable or a guarded subtype-typed index, with no arithmetic on loop-carried values, so checks are routine and no annotation is needed. Digits stay as characters in a bounded buffer, so the 22-digit stretch case needs no big numbers.

Position 989 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Each test number is an embedded digit string copied into a fixed 22-character buffer with a length; one procedure scans right to left with a reverse for loop and exit for the rightmost position with a larger digit after it, then finds the smallest larger digit to its right, swaps, and bubble-sorts the suffix with nested for loops. If no such position exists the result is the string "0"; the main body calls the procedure for all eight values plus the 22-digit stretch value and prints each with Put_Line. About 90 lines.

## Proof obligations to watch

- **index**: Scan, bubble-sort and swap indexes come from for-loop variables over the buffer's own range or from Lower and Higher subtype-bounded index variables, with a Found guard before use, so no invariant is needed.
- **initialization**: Lower and Higher are given default values up front and only read after the Found guard, so flow analysis passes.
- **length**: Inputs are checked to be digits and at most 22 long before copying into the fixed 22-slot buffer, with invalid input rejected visibly.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, unconstrained arrays, string indexing, string building, Boolean objects, for loops, while loops, procedures and conditional expressions.

## External effects

- **console output** (allowed): Prints each test number and its next highest result line by line.

Assessed on 2026-10-15 against page revision 412141 of the [task](https://rosettacode.org/wiki/Next_highest_int_from_digits) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
