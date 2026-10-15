# Terminal control/Ringing the terminal bell

**Candidate: proofs likely to discharge automatically.** The program is one constant Character written to standard output, so every check is trivial and the only needed growth is a character-valued Put in Silver_IO. The task is satisfied by writing the BEL byte, with no terminal-control library needed.

Position 433 in the [progression](../../../progression.md#stage-11), in stage 11.

## Approach

A parameterless Main procedure with SPARK_Mode (On) emits one Character constant with value Character'Val (7) through a Silver_IO output operation without a line terminator. There are no loops, arithmetic, inputs or guards, so no proof obligations arise. About 8 lines.

## Language surface beyond today's Silver

Characters and Put without a newline.

## External effects

- **console output** (allowed): Writes the single BEL character (ASCII 7) to standard output, which the terminal turns into its bell.

Assessed on 2026-10-15 against page revision 415095 of the [task](https://rosettacode.org/wiki/Terminal_control/Ringing_the_terminal_bell) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
