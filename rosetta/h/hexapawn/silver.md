# Hexapawn

**Candidate: proofs plausibly discharge automatically.** Every operation works on small fixed-size arrays and enumerations with range-typed indices and bounded loops inside procedures, so no invariant is needed, though the interactive parsing and large learned-move table require careful program shape. No recursion, heap or annotation is required, and learned state lives in memory for one run.

Position 1257 in the [progression](../../progression.md#stage-21), in stage 21.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The board is a nine-element array of a Spot enumeration (empty, computer, player); a procedure generates legal moves into a bounded array of move records with a count, and each position is encoded as a base-3 integer indexing a fixed-size table of Boolean flags recording which moves the computer has not yet discarded. The computer picks among remaining legal moves with a deterministic linear congruential generator, a main procedure plays games reading the human's two squares from stdin with validation and a retry message, and after each computer loss it clears the flag for the last move taken in the relevant position. An optional deterministic trainer plays the computer against a fixed opponent for a bounded number of games, and play ends on 'n' or end of input. About 260 lines.

## Proof obligations to watch

- **index**: Board squares, the base-3 position code (0..19682) and move slots are indexed only via range-typed values or explicit guards, and parsed player squares are rejected with a message unless within 1..9.
- **overflow**: The position code accumulates across a for loop over nine squares, so the accumulator is declared with a range type 0..19682 and each digit comes from a bounded enumeration position, needing no invariant.
- **termination**: The game loop, retry-on-invalid-move loop and learning loop are while loops kept inside procedures, with play bounded by a move counter, since functions would need a variant.
- **initialization**: The learned-move table (about 19683 by 27 Booleans) and the board must be fully initialized by aggregate or loop before use.
- **other**: Learning discards the last move taken in a losing position, and an explicit guard resets that position's options when none remain, giving a specified fallback instead of silently altering results.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, records, string indexing, string building, text parsing, case statements, for loops, while loops, procedures, functions, Put without a newline, standard input and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the board, the computer's moves, the winner and the win tally.
- **standard input** (allowed): Reads the player's from and to squares and the play-again answer, with a specified outcome for end of input or malformed lines.

Assessed on 2026-10-15 against page revision 414955 of the [task](https://rosettacode.org/wiki/Hexapawn) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
