# Smith–Waterman algorithm

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded by small fixed sizes and ranged score types, and every index is guarded, so no annotation is needed. The 2D array, clamped max computations and the reversed traceback buffers need careful shaping, hence plausible rather than likely.

Position 719 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

The two example sequences (8 characters each) are embedded as constants with fixed capacity, and the matrix H is a two-dimensional array of a ranged score subtype indexed 0..8 by 0..8. Nested for loops fill H with the recurrence, tracking the best score and its cell. A while loop in a procedure traces back from that cell until H is 0 or an index reaches 0, appending characters to bounded buffers that are then reversed and printed with the score. About 120 lines.

## Proof obligations to watch

- **index**: Traceback indexes the matrix with decrementing i and j, so each decrement is guarded by a test that i and j are above 0 immediately before it.
- **overflow**: Cell scores are held in a ranged subtype wide enough for 2 * 64 bound sequences and each recurrence term is clamped before storing, so the sums stay in range.
- **termination**: The traceback while loop lives in a procedure, which gets no termination check, and each step also decreases i or j.
- **length**: Aligned output is built in fixed buffers sized to the sum of both sequence capacities, with a guard on the fill position before each character append.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, 'Image of scalars, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the score, the aligned substrings and the alignment path.

Assessed on 2026-10-15 against page revision 414476 of the [task](https://rosettacode.org/wiki/Smith%E2%80%93Waterman_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
