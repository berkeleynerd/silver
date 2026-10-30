# Sort an outline at every level

**Candidate: proofs plausibly discharge automatically.** Every array index and buffer length is bounded by fixed capacities with explicit guards that report an invalid outline, and all loops live in procedures, so nothing needs an annotation, though many loop-carried offsets need careful guarding.

Position 1489 in the [progression](../../progression.md#stage-28), in stage 28.

## Approach

The six embedded test outlines are fixed-capacity arrays of records holding a bounded line buffer and length; a procedure measures each line's leading whitespace, validates it (mixed tabs and spaces, width not a multiple of the unit taken from the first indented line) and prints a warning and skips sorting on failure. For valid outlines it builds per-line sort keys from an ancestor stack (each level's text joined with a separator character), orders the lines with a bounded insertion sort comparing keys ascending or descending, and prints the original lines with their untouched indentation. About 260 lines.

## Proof obligations to watch

- **index**: Indent scanning, ancestor-stack depth and key-building offsets are loop-carried, so each is clamped by an explicit guard against the fixed capacities and a too-deep or too-long line is reported as an outline error.
- **length**: Sort keys concatenate ancestor lines into fixed-capacity buffers, so a guard before each append checks the remaining room and rejects an outline that would overflow.
- **overflow**: Indent widths and counters are declared with small ranged subtypes bounded by the line capacity, so arithmetic and the width mod unit check stay in range.
- **termination**: All scans and sorts are for loops or while loops inside procedures, so no termination check is generated.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, string indexing, string building, string ordering, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the sorted outlines and the inconsistency warnings with Put_Line.

Assessed on 2026-10-15 against page revision 414485 of the [task](https://rosettacode.org/wiki/Sort_an_outline_at_every_level) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
