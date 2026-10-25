# Empty string

**Candidate: proofs likely to discharge automatically.** The task needs only String constants, length comparisons and if statements, which Silver already largely has, so no proof obligation exists beyond trivial ones.

Position 86 in the [progression](../../progression.md#stage-5), in stage 5.

## Approach

The program declares a String constant "" and a non-empty String constant, then tests emptiness with 'Length = 0 and non-emptiness with 'Length > 0 (or equality with ""), printing one Put_Line result per case. The checks run in plain if/else statements, and a Boolean variable can hold each result. There are no loops or arithmetic, and no input beyond the embedded data. About 30 lines.

## Language surface recorded by this assessment

Boolean objects.

## External effects

- **console output** (allowed): The program prints a line for each demonstrated check so the result is visible.

Assessed on 2026-10-15 against page revision 412762 of the [task](https://rosettacode.org/wiki/Empty_string) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
