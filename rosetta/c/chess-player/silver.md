# Chess player

**Candidate: proofs plausibly discharge automatically.** Nothing in the task conflicts with the Oracle, and all checks come from board bounds, fixed capacities and guards, but the program is large and the iterative search must avoid recursion and function loops, so discharge depends on careful program shape.

Position 1465 in the [progression](../../progression.md#stage-27), in stage 27.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

The board is a constrained 8x8 array of piece enumeration values, moves are records in a fixed-capacity array, and a procedure-based game loop alternates between a validated human move read from stdin and a fixed-depth computer search. The search is an iterative alpha-beta using an explicit bounded stack of move lists rather than recursion, and every square offset is guarded to stay on the board before indexing. About 700 lines.

## Proof obligations to watch

- **index**: Board and move-list indexing needs every offset square guarded to lie on the 8x8 board and the move list guarded against exceeding its fixed capacity, which explicit checks before each step discharge.
- **termination**: Search is written as an iterative alpha-beta with an explicit fixed-depth stack inside procedures, since recursive functions would need variants, so while loops get no termination check.
- **overflow**: Evaluation scores and node counters are carried through loops, so they need ranged types or saturating guards with a visible outcome.
- **range**: Parsing the user's move text must validate file, rank and length before converting to square indexes, rejecting bad input with a specified message and re-prompt.
- **other**: Chess rules such as castling, en passant, promotion and draw detection add much shaped state, though each is plain bounded-array logic.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, records, string indexing, string building, case statements, for loops, while loops, procedures, functions, packages, Put without a newline, standard input, text parsing and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the board, prompts and the computer's moves as text.
- **standard input** (allowed): Reads the human player's moves as lines of text from standard input.

Assessed on 2026-10-15 against page revision 414601 of the [task](https://rosettacode.org/wiki/Chess_player) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
