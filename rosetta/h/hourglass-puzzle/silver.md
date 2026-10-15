# Hourglass puzzle

**Candidate: proofs likely to discharge automatically.** All state is small bounded integers updated by guarded transitions inside a procedure-based while loop with a fixed move cap, so every check follows from types and guards without invariants.

Position 1221 in the [progression](../../progression.md#stage-21), in stage 21.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The program keeps elapsed time and the sand remaining in the upper bulb of each of the two hourglasses as bounded integers, and a procedure reads one command line at a time from standard input in a while loop capped at a fixed number of moves. Each command (flip 4, flip 7, or wait until the next glass runs out) advances time by a guarded amount and updates the sand state, while unrecognised commands or end of input print a rejection outcome. The game ends with a success message when exactly 9 minutes have been measured between a start and a stop command. About 70 lines.

## Proof obligations to watch

- **overflow**: Elapsed time and sand counters are ranged integers with a capped move count, and each update is guarded by a comparison just before it.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, while loops, procedures, standard input and Put without a newline.

## External effects

- **console output** (allowed): Prompts, the elapsed and remaining sand state, and the final result are printed.
- **standard input** (allowed): The one-player game reads the player's move lines (flip 4, flip 7, wait) from standard input.

Assessed on 2026-10-15 against page revision 414258 of the [task](https://rosettacode.org/wiki/Hourglass_puzzle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
