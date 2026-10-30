# Cistercian numerals

**Candidate: proofs plausibly discharge automatically.** Every check follows from subtypes, constant tables and for-loop indexes over fixed bounds with no loop-carried accumulator, but the coordinate arithmetic needs careful range-subtype design to discharge unaided.

Position 824 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed the eight example values in a constant array of a 0 .. 9999 subtype, split each into four digits with / and mod, and map each digit through a constant table of stroke flags for the five strokes. Draw the strokes for each quadrant into a fixed-size Boolean grid with for loops over stroke and step, using a constant table of start offsets and directions per quadrant, then convert each row to a fixed-length String of '|', '-', '/', '\' or space characters and print it with Put_Line. All of it lives in a single Main with small local procedures, with no input and no recursion. About 130 lines.

## Proof obligations to watch

- **range**: Stroke walking updates row and column positions in nested for loops, so each coordinate is computed as a base plus step times the loop index inside a clamped subtype, and the grid index range is chosen so the extremes stay within bounds.
- **index**: Grid and row-string indexing uses coordinates of a subtype equal to the array index range, with constant stroke tables, so no invariant is needed.
- **overflow**: The digit split with / and mod on a value of subtype 0 .. 9999 yields results bounded by the types, so only simple division range checks arise.
- **length**: Each output row is a fixed-length String assigned from a same-length buffer, and the heading is concatenated with the Image of a bounded value, so its length is statically bounded.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, records, string indexing, string building, 'Image of scalars, case statements, for loops, procedures, functions and Boolean objects.

## External effects

- **console output** (allowed): Prints each numeral as a text-art grid, one line per row, using Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 412398 of the [task](https://rosettacode.org/wiki/Cistercian_numerals) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
