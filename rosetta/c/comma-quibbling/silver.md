# Comma quibbling

**Candidate: proofs likely to discharge automatically.** Everything is bounded iteration over fixed-capacity arrays and a bounded output buffer, so every index and length check follows from range types and one capacity guard before each append, with no recursion, while loops in functions, or annotations needed.

Position 980 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Words are held in a fixed array of fixed-width String slots with a parallel array of lengths (or a record per word), and a procedure Quibble takes the word array and a count and builds the result into a bounded String buffer with a ranged Natural position. It branches on count (0, 1, 2, 3 or more), appends the braces, separators and words with a for loop over the first Count-1 words, guarding capacity before every append, then main runs the four embedded test inputs and prints each result slice with Put_Line. About 70 lines.

## Proof obligations to watch

- **index**: The write position is a loop-carried value, so before each append a guard compares it with the buffer capacity and, on failure, emits a visible rejection, which lets the slice-assignment index and length checks discharge from the position's range type.
- **length**: Each word's stored length is a subtype bounded by the word slot width, so slicing a word to its length is within bounds without an invariant.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, string indexing, string building, for loops, procedures, unconstrained arrays and records.

## External effects

- **console output** (allowed): Prints the four quibbled result lines for the embedded test inputs with Put_Line.

Assessed on 2026-10-15 against page revision 414122 of the [task](https://rosettacode.org/wiki/Comma_quibbling) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
