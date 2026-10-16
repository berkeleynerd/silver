# Align columns

**Candidate: proofs plausibly discharge automatically.** All checks follow from fixed-capacity arrays, range-typed counters and guards before each index or pad computation, but many loop-carried positions and widths need careful shaping, so the outlook is plausible rather than likely.

Position 624 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The six embedded lines are concatenated into one constant String with a line-break marker character, and a for loop over its range records each word's line, column, start and length into fixed-capacity arrays (at most 6 lines by 16 columns). Column widths are maxima over those words, then for each of three alignment modes a procedure builds each line in a bounded buffer, adding computed left/right/center padding (center uses integer division) and prints it with Put_Line. Every index and count is a range-typed variable guarded just before use, and overflowing the fixed capacities leads to a visible rejection. About 110 lines.

## Proof obligations to watch

- **index**: Word start and end positions are loop-carried, so each is stored in a range-typed variable bounded by the fixed text length and guarded before slicing or indexing into the line buffer.
- **overflow**: Column widths and padding counts are subtypes bounded by the maximum word length, and padding is computed only after a guard that the word fits its column.
- **length**: The output buffer has a fixed capacity sized for the widest aligned line (columns times maximum width), and appends are guarded by remaining space so the length check holds.
- **termination**: Any while loop scanning for the next dollar sign lives in a procedure, so no termination check arises, and for loops cover the rest.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The aligned text is printed line by line for left, right and center justification.

Assessed on 2026-10-15 against page revision 414611 of the [task](https://rosettacode.org/wiki/Align_columns) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
