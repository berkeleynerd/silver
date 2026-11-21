# RCRPG

**Candidate: proofs plausibly discharge automatically.** Every check is a bounded-grid index or bounded-counter range check that an explicit guard just before the operation discharges, and the only loop is a while loop in a procedure, so no annotation is needed. The task needs stdin line reading and string-command parsing that Silver lacks today, but nothing conflicts with the Oracle.

Position 1236 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The world is a small fixed 3D grid (for example 0..4 per axis) with a record per room holding Boolean walls or passages and item counts, plus a player record with position and bounded inventory counts of sledge, gold and ladder. A procedure reads commands from stdin until end of input, parses them by comparing the first characters (move n/s/e/w/up/down, take, drop, dig with sledge, look), and applies each only after explicit guards on grid bounds, passage existence, ladder presence and inventory counts. Reaching the goal coordinate prints a win message and ends the loop, and unknown commands print a visible rejection. About 170 lines.

## Proof obligations to watch

- **index**: Moves compute x+1 or z-1 into a bounded 3D grid, discharged by an explicit boundary guard before each step that prints a visible 'you cannot go that way' message.
- **range**: Inventory counts and player coordinates are subtypes, so each increment is guarded by a comparison with the subtype limit just before the update.
- **length**: Input lines are read into a fixed-capacity buffer, and over-long lines are rejected with a visible message rather than truncated.
- **termination**: The command loop is a while loop inside a procedure, so no termination check applies, and end of input exits it.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, records, string indexing, string building, 'Image of scalars, case statements, for loops, while loops, procedures, functions, Put without a newline, standard input and integer division.

## External effects

- **console output** (allowed): Prints room descriptions, inventory and win or error messages.
- **standard input** (allowed): Reads the player's commands line by line, with end of input ending the game.

Assessed on 2026-10-15 against page revision 414422 of the [task](https://rosettacode.org/wiki/RCRPG) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
