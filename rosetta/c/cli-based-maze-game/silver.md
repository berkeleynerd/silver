# CLI-based maze-game

**Excluded from Silver: clock.** The task is a text maze game: a randomly generated bounded grid, hero moves from typed commands, and monsters, bombs, treasure and revolving doors updated by plain game logic. Monsters can move after each hero move instead of in a forked process, and a bounded-array grid with a seeded pseudo-random generator fits Silver, so nothing breaks an Oracle rule.

## Language surface beyond today's Silver

Integers, characters, arrays, records, enumerations, loops and subprograms.

## External effects

- **console output** (allowed): Prints the maze grid with the symbols @ * . $ X b -o- and the status after each turn.
- **standard input** (allowed): Reads the player's line-based commands (move, bomb, quit) from standard input, validating each one.
- **clock** (not allowed): Seeds a deterministic pseudo-random generator from the time so the maze differs at each start.

Assessed on 2026-10-15 against page revision 375482 of the [task](https://rosettacode.org/wiki/CLI-based_maze-game) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
