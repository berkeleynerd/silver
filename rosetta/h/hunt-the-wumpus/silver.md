# Hunt the Wumpus

**Candidate: proofs plausibly discharge automatically.** Every array access is by a ranged room subtype, arithmetic is bounded by types, and all loops live in procedures, so checks should discharge from types and guards, but the pile of loop-carried game state, input parsing and the PRNG need careful shape. No annotation is required and the Ada solution's exception handlers are replaced by explicit input validation.

Position 1243 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The program keeps the dodecahedron as a constant 20x3 array of room numbers and the game state (player, Wumpus, two bats, two pits, arrows) as ranged variables, with distinct hazard rooms chosen by a deterministic LCG and scan-or-resample loops in procedures. A while loop in a procedure reads one command per line from stdin, parses move or shoot and a validated room number, rejects non-adjacent or malformed targets with a message, and applies the rules (Wumpus or pit loss, bat transport to an empty room, shot hit or miss with a 75 percent LCG-driven Wumpus move, arrow exhaustion loss); end of input ends the game with a specified message. About 230 lines.

## Proof obligations to watch

- **index**: Room numbers are a 0..19 subtype and the adjacency table is a constant 20x3 array, so lookups are safe, but typed player input must be parsed and range-guarded before conversion to a room.
- **overflow**: The deterministic LCG multiplies a seed held in a bounded range subtype followed by mod, so a seed range small enough to keep the product within Integer discharges it by types alone.
- **termination**: The main game loop and the rejection-sampling placement loops are while loops, which are acceptable only inside procedures (no termination check), so placement and play stay in procedures and avoid functions with loops.
- **initialization**: Game state (positions, arrow count, seed) is held in local variables of Main and every one is assigned before first use, passed as in out parameters to helper procedures.
- **length**: Command lines and numeric tokens are read into bounded String buffers with explicit length guards, and over-long or non-numeric input is rejected with a printed message.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, string indexing, string building, 'Image of scalars, text parsing, case statements, for loops, while loops, procedures, functions, Put without a newline and standard input.

## External effects

- **console output** (allowed): Prints room descriptions, sensed hazard messages, prompts and win or loss outcomes.
- **standard input** (allowed): Reads the player's move or shoot commands and target room numbers line by line, with a specified outcome for invalid or ended input.

Assessed on 2026-10-15 against page revision 414261 of the [task](https://rosettacode.org/wiki/Hunt_the_Wumpus) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
