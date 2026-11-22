# Zhang-Suen thinning algorithm

**Candidate: proofs likely to discharge automatically.** All array indexing is over constant interior ranges and all counters are small ranged values, so every check follows from types and loop bounds; the only unbounded loop is a while loop in a procedure, which gets no termination check.

Position 671 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Store the embedded 10-by-32 image as a two-dimensional Boolean array filled from constant row strings, with a second array for the next generation. A procedure loops while a Changed flag is set, running step 1 and step 2 as nested for loops over interior pixels only, computing B and A with fixed straight-line if statements, noting deletions in a marker array and then clearing them after each pass. Output builds each row in a fixed 32-character String buffer and prints it with Put_Line before and after thinning. About 95 lines.

## Proof obligations to watch

- **index**: Neighbour accesses at x-1, x+1, y-1 and y+1 are safe because the pixel loops run over the interior subranges 2..Rows-1 and 2..Cols-1 of constant bounds.
- **overflow**: The neighbour count and transition count are small counters of a range 0..8 type incremented in straight-line code at most eight times, so the provers bound them without an invariant.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the input image and the thinned image as rows of text art.

Assessed on 2026-10-15 against page revision 414598 of the [task](https://rosettacode.org/wiki/Zhang-Suen_thinning_algorithm) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
