# Go Fish

**Candidate: proofs plausibly discharge automatically.** Fixed-size count arrays, a bounded deck and procedure-based while loops mean every check follows from types and guards, but several loop-carried counters need explicit guards because no invariant can state that each rank has at most 4 cards.

Position 1254 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

Hands are two arrays of per-rank card counts (13 ranks, small ranged counts), the deck is a 52-element rank array shuffled by a deterministic LCG-driven Fisher-Yates with a next-card index, and books and scores are small ranged counters. The main loop is a while loop inside a procedure: it reads the player's requested rank line from stdin, validates it (invalid or unheld rank re-prompts, end of input rejects), transfers or draws with explicit guards, removes completed books, and the computer asks for a rank it holds, preferring ranks the player previously asked for. The game ends when the deck and hands are empty, and the program prints the scores and the winner. About 230 lines.

## Proof obligations to watch

- **overflow**: Moving cards between per-rank counts cannot be shown to stay at or below 4 without an invariant, so each addition is guarded by a bound check against the count type's maximum, with a visible internal-error outcome that is never taken in play.
- **overflow**: The LCG multiply and add are kept in range by using a wide ranged type with a small modulus or by reducing operands with mod before multiplying.
- **index**: The deck position is loop-carried, so each draw is guarded by a check that the next-card index is below 52 and an empty deck gives the specified outcome of no draw.
- **range**: Scores, book counts and the turn counter are loop-carried and must be typed or guarded to stay within their ranges.
- **termination**: The game loop and the input retry loop are while loops inside procedures, which get no termination check, so none is needed.
- **other**: Rank-parsing and the AI's choice among held ranks need loops over the 13 ranks with guards, and end-of-input must be handled as a specified outcome.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, functions, case statements, Put without a newline and standard input.

## External effects

- **console output** (allowed): Prompts, hand display, move narration and final scores are printed as text.
- **standard input** (allowed): The human player types the rank to ask for each turn.

Assessed on 2026-10-15 against page revision 414951 of the [task](https://rosettacode.org/wiki/Go_Fish) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
