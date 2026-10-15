# Sokoban

**Candidate: proofs plausibly discharge automatically.** Every check comes from declared grid bounds, modular hash arithmetic and explicit capacity guards, and all loops sit in procedures so no termination variants are needed, but the many loop-carried queue indexes and large arrays make the shape demanding.

Position 1320 in the [progression](../../progression.md#stage-23), in stage 23.

## Approach

The 8-row by 7-column level is embedded as an array of strings, converted to a wall grid plus a box array and a player position; a breadth-first search over (player, box set) states runs in a main procedure with a fixed-capacity queue, parent indexes, a move-letter array, and an open-addressing hash set of visited states. Each step tries four directions with row and column bounds guards, performs a move or a push, rejects states when the queue or table is full, and on reaching a solved board walks the parent chain into a bounded LURD buffer that is printed. Capacity exhaustion and no-solution each produce a specified message. About 230 lines.

## Proof obligations to watch

- **index**: Neighbour lookups of the player and box cells stay inside the grid because a guard on row and column bounds precedes each access, and the level's outer wall also stops moves.
- **overflow**: The state hash uses a modular type so wraparound is intended, and the table index comes from a mod by the fixed table size, which is a range-safe conversion.
- **index**: Queue head, tail and the parent chain are loop-carried values, so each use is guarded by an explicit tail-below-capacity test that reports a visible 'search limit reached' outcome instead of dropping states.
- **initialization**: The large queue, parent and visited arrays must be initialized wholesale with aggregates rather than by loops, since flow analysis cannot see loop-based array initialization.
- **range**: Solution reconstruction walks the parent chain into a bounded character buffer, and the walk depth is capped by a guard on the buffer length with a visible overflow outcome.
- **stack**: A multi-megabyte queue declared in the main procedure leaves stack size as an unproven environmental premise, though the capacity is a fixed documented limit.

## Language surface beyond today's Silver

Integers, integer division, modular types, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, records, string indexing, string building, case statements, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the embedded level and the LURD solution string, or a specified no-solution or limit-exceeded message.

Assessed on 2026-10-15 against page revision 414477 of the [task](https://rosettacode.org/wiki/Sokoban) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
