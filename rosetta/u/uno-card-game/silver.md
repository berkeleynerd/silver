# Uno (card game)

**Candidate: proofs plausibly discharge automatically.** Nothing requires an annotation because all state lives in bounded arrays and ranged counters guarded before each use and all loops are while loops inside procedures, but the large amount of loop-carried game state means careful guard placement is needed.

Position 1262 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The program uses a record per card (color and kind enumerations), a 108-card deck array, a 4-by-108 hand array with per-player counts, and a linear-congruential shuffle with fixed bounds. A procedure-based round loop deals seven cards, handles skip, reverse, draw-two, wild and wild-draw-four effects, uno calls, the draw-four challenge penalty and reshuffling, with the human choosing from validated stdin lines and the bots using a fixed deterministic policy. Rounds repeat, scoring the remaining hands, until a player reaches 500 points. About 450 lines.

## Proof obligations to watch

- **index**: Deck top, discard count and each hand count are loop-carried across turns, so every draw, play and removal is guarded by an explicit count and range test (reshuffling the discard pile when the deck is empty) before indexing fixed 108-card arrays.
- **overflow**: Scores, hand counts and the deterministic shuffle generator use bounded ranged types with a small multiplier and mod, and score sums are capped by the 500-point game end, so each addition is range-guarded.
- **range**: Parsed human menu input is validated against the current hand size and invalid input gets a visible re-prompt, so no unchecked index reaches an array.
- **termination**: The turn and round loops are while loops inside procedures, which get no termination check, so none is required, though a turn cap may be needed to bound play.
- **initialization**: The deck, hands and discard arrays must be fully initialized by loops before use, which flow analysis can miss for partially filled arrays unless whole-array aggregates are used first.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, enumerations, arrays, multidimensional arrays, records, case statements, for loops, while loops, procedures, functions, string building, 'Image of scalars, text parsing, Put without a newline and standard input.

## External effects

- **console output** (allowed): Prints the top card, the human player's visible hand, bot actions, uno calls, penalties and scores as text.
- **standard input** (allowed): The human player reads a menu choice per turn, plus color declarations and challenge decisions, as lines from standard input.

Assessed on 2026-10-15 against page revision 414564 of the [task](https://rosettacode.org/wiki/Uno_%28card_game%29) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
