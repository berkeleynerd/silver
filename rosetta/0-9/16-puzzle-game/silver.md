# 16 puzzle game

**Candidate: proofs likely to discharge automatically.** All indexes derive from validated characters mapped to 1..4 ranged subtypes, loops are for loops or live in procedures, and arithmetic is small and bounded, so every check follows from types and guards.

Position 1230 in the [progression](../../progression.md#stage-21), in stage 21.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The program keeps the 4x4 grid as a 16-element array of 1..16 (or a 4x4 array), scrambles it with a fixed number of random-looking row or column rotations from a small deterministic LCG with a fixed seed, then loops in a procedure reading a command line each turn. A command is validated by length and letter/digit characters, mapped to a rotation of one row or column using for loops over 1..4, then the grid is printed as text and compared to the solved order; Q quits, S rescans, and invalid input prints a message. About 130 lines.

## Proof obligations to watch

- **index**: Row and column indexes come from a validated command letter and digit mapped into subtypes 1..4, so every grid access is within range; invalid commands are rejected with a message.
- **termination**: The interactive loop and the scramble loop are in a procedure (no termination check), and the scramble uses a for loop with a fixed move count and a deterministic generator.
- **overflow**: The move counter and the generator state are bounded by a declared range with a guard that stops play or wraps the generator via mod on a small modulus, so no overflow can occur.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, 'Image of scalars, case statements, for loops, while loops, procedures, functions, Put without a newline and standard input.

## External effects

- **console output** (allowed): Prints the grid, the move count and the win message as text.
- **standard input** (allowed): Reads the difficulty choice and each move command (D1..D4, U1..U4, L1..L4, R1..R4, Q, S) from standard input.

Assessed on 2026-10-15 against page revision 414033 of the [task](https://rosettacode.org/wiki/16_puzzle_game) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
