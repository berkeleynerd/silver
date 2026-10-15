# Number triplets game

**Candidate: proofs plausibly discharge automatically.** The task is a vague interactive tile-sliding puzzle whose mouse and window parts can be replaced by text commands on stdin and a text board, and all checks follow from bounded array subtypes and guards on validated input. It is plausible rather than likely because of the moderate amount of loop-carried state, text parsing, and move-rule logic that needs careful guards.

Position 1246 in the [progression](../../progression.md#stage-21), in stage 21.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The 5x9 board is a two-dimensional array of cell kinds (blue, black, white, yellow, red) plus a parallel array of tile labels 1 to 4, initialized and shuffled in rows 3 to 5 by Fisher-Yates driven by a small deterministic generator. A procedure loops reading lines such as a select command or a move command, validates ranges and the rule that tiles move only onto yellow or blue cells, applies the move, and reprints the text board with the move count. After every move a win check compares each red row against 1,2,3,4 and prints the win message with the move count. About 170 lines.

## Proof obligations to watch

- **index**: Row and column come from parsed input, so each move is validated against the 5x9 subtype bounds and rejected with a printed message before any array access.
- **overflow**: The deterministic generator and the move counter are kept inside ranged subtypes (counter saturating at a stated limit), so the arithmetic cannot overflow.
- **termination**: The input-reading game loop is a while loop inside a procedure, which gets no termination check, and it ends at end of input or a quit command.
- **initialization**: Board arrays and selection state are fully initialized by an initialization loop before play, so data-flow checks are routine.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, 'Image of scalars, text parsing, case statements, for loops, while loops, procedures, functions, Put without a newline and standard input.

## External effects

- **console output** (allowed): Prints the text board, move count and win message each turn.
- **standard input** (allowed): Reads move commands as lines of text in place of mouse clicks.

Assessed on 2026-10-15 against page revision 371230 of the [task](https://rosettacode.org/wiki/Number_triplets_game) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
