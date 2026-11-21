# Four sides of square

**Candidate: proofs likely to discharge automatically.** Every check follows from the validated Side_Length subtype and for loops over the array's own bounds, so no annotation is needed. The GUI request is optional and text output satisfies the task.

Position 1359 in the [progression](../../progression.md#stage-23), in stage 23.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

The program parses the first argument with a validating text-parse into a subtype Side_Length 1..40, rejecting anything else with a usage message and nonzero exit status. It fills a constrained two-dimensional Character array of Max_Side by Max_Side with nested for loops, using 1 on the border cells and 0 elsewhere, then prints each row of the used size through a fixed-length bounded string buffer with Put_Line. All loops are for loops over ranges bounded by the validated length. About 45 lines.

## Proof obligations to watch

- **index**: The row and column indexes are for-loop variables over the constrained array's own range, and the output line buffer is sized for the maximum side length, so every index discharges.
- **range**: The parsed length is validated against 1..Max_Side (Max_Side is a documented limit such as 40) before use; invalid or missing input is rejected with a usage message.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, multidimensional arrays, string building, text parsing, for loops, procedures, conditional expressions, Put without a newline and exit status.

## External effects

- **console output** (allowed): The program prints the square as lines of text.
- **arguments** (allowed): The side length is read from the first command-line argument.

Assessed on 2026-10-15 against page revision 411282 of the [task](https://rosettacode.org/wiki/Four_sides_of_square) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
