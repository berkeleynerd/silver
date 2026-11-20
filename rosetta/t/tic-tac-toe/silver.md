# Tic-tac-toe

**Candidate: proofs likely to discharge automatically.** Every check is an index or range on a fixed 9-cell board, a bounded generator, or a for loop with a visible guard, and no while loop sits inside a function, so no annotation is needed; interactive human input is optional and is left out in favour of the deterministic computer players.

Position 458 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

The board is a 9-element Character array (digits for free cells, 'X' or 'O' once played) and a computer-versus-computer game is driven by a small deterministic generator that picks a start cell, then a bounded for loop scans all 9 cells from there to find the first free one, so every move is legal by construction. A for loop over at most 9 turns, guarded by a Done flag instead of an exit, plays alternate marks, prints the board after each move, and a winner function compares the 8 constant line triples (rows, columns, diagonals) to announce a win or a draw. About 95 lines.

## Proof obligations to watch

- **overflow**: The deterministic generator state is a ranged subtype and each update is a small multiply, add and mod that fits Integer, so the range checks follow from the types.
- **index**: Cell scans use a wrapped index of the form ((start + offset) mod 9) + 1 on a 1..9 array, which the provers discharge from the mod bound, and win lines come from a constant table of in-range indexes.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, Boolean objects, arrays, for loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The program prints the board after each move, each move announcement, and the final win or draw notice.

Assessed on 2026-10-15 against page revision 414988 of the [task](https://rosettacode.org/wiki/Tic-tac-toe) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
