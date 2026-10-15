# Display an outline as a nested table

**Candidate: proofs plausibly discharge automatically.** Everything is fixed-size arrays and for loops in procedures with no recursion, so checks follow from subtype ranges and a few explicit guards, but the many loop-carried indices and sums and the string-building of each markup line make the shape of the program matter.

Position 952 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

The embedded outline is stored as a constant array of records holding an indent level (a ranged subtype 0..3) and a bounded text with explicit length. Procedures compute each node's parent via a reverse for loop, accumulate leaf widths from the last line backward into parents, and derive a color index from each node's level-two ancestor. A for loop over levels then emits one table row per level, printing each node's cell with colspan and an empty cell for each leaf shallower than that level, and the program rejects an outline whose indent jumps by more than one level or exceeds capacity. About 170 lines.

## Proof obligations to watch

- **index**: Finding each node's parent by scanning backward over the level array is a loop-carried index, discharged by a guard that stops the scan at index 1 and by using a for loop in reverse over the array range.
- **overflow**: Leaf-count sums accumulated into parents stay inside a subtype capped at the line capacity, with an explicit guard that rejects the outline rather than exceed it.
- **length**: Building each markup line from a bounded text buffer plus fixed prefixes and an integer image needs the buffer size and line capacity chosen so the concatenation length provably fits.
- **other**: Level-wise row emission requires nested loops over lines and levels, so each cell needs a guard, and the empty padding cells for shallow leaves must be emitted explicitly rather than skipped.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, records, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, functions and conditional expressions.

## External effects

- **console output** (allowed): The wiki table markup is written line by line to standard output.

Assessed on 2026-10-15 against page revision 414160 of the [task](https://rosettacode.org/wiki/Display_an_outline_as_a_nested_table) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
