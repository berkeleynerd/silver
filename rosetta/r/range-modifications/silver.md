# Range modifications

**Candidate: proofs plausibly discharge automatically.** All operations are bounded array scans and shifts over a small fixed capacity, with no recursion and no annotations needed, so checks follow from subtype ranges and guards before each access. The work lies in careful guarding of index shifts, boundary arithmetic and string-building lengths, hence plausible rather than likely.

Position 629 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Keep the sequence as two fixed-capacity arrays of low and high bounds (about 16 entries) with a count, and embed the three example sequences and step lists as data. Add and Remove procedures scan with for loops to find the covering or adjacent range, then extend, merge, split or delete by shifting entries with for loops, all guarded by the count being below capacity. A Format procedure builds the comma-separated text into a bounded buffer using Image and length guards, and the main program prints it after each step. About 170 lines.

## Proof obligations to watch

- **index**: Shifting ranges on insert, split and delete uses for loops over the count with a guard that the count is below capacity just before each insert, and a visible rejection message when the table is full.
- **overflow**: Boundaries are declared in a bounded integer subtype well inside Integer and the added integer is range-guarded, so the x-1 and x+1 adjacency tests and merges cannot overflow.
- **length**: The output buffer is sized for capacity times the maximum range text, and a guard before each append checks the loop-carried length, so appends and Image slices cannot exceed bounds.
- **range**: The loop-carried count and positions are held in subtypes bounded by capacity, and the neighbor-merge conditions are guarded explicitly before each array access.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, string building, 'Image of scalars, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the starting sequence and the resulting sequence after each add or remove step.

Assessed on 2026-10-15 against page revision 396629 of the [task](https://rosettacode.org/wiki/Range_modifications) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
