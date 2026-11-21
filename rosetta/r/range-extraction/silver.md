# Range extraction

**Candidate: proofs plausibly discharge automatically.** Everything is bounded and iterative with an embedded input, so only the buffer-index and length checks on loop-carried positions need careful guard placement, and no annotation is needed. Integer-to-text conversion into the buffer adds some shape-dependence, hence plausible rather than likely.

Position 555 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Embed the 33 integers in a constant array of a bounded integer subtype, and scan with a for loop that tracks the start of the current run, calling a procedure to flush each run into a fixed-capacity Character buffer with a Length counter. The flush procedure appends a comma if needed, the start value's digits, then either nothing, a comma plus the end (run of two), or a dash plus the end (run of three or more), with a capacity guard before every append. The final slice of the buffer is printed with Put_Line. About 80 lines.

## Proof obligations to watch

- **index**: Run scanning and output-buffer writes are loop-carried, so each write is preceded by a guard comparing the position against the buffer capacity, with an overflow outcome of a visible rejection.
- **overflow**: Element values are a declared bounded subtype (for example 0 .. 1000) so that S(I)+1 and digit extraction cannot overflow, while the Length accumulator is kept in the buffer-capacity range by guards.
- **termination**: Any while loop (digit extraction) lives in a procedure, which gets no termination check, and the outer scan is a for loop.
- **length**: The output is built in a fixed-capacity String buffer with an explicit length, and the final slice 1 .. Length is guarded to stay within the capacity.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, for loops, while loops, string indexing, string building, 'Image of scalars, procedures and functions.

## External effects

- **console output** (allowed): Prints the single formatted range line with Put_Line.

Assessed on 2026-10-15 against page revision 411718 of the [task](https://rosettacode.org/wiki/Range_extraction) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
