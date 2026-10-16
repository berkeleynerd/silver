# Two's complement

**Candidate: proofs likely to discharge automatically.** Modular arithmetic wraps by definition and so raises no overflow check, and the program is straight-line code over constants, so every proof is routine.

Position 1263 in the [progression](../../progression.md#stage-23), in stage 23, which adds modular types.

## Approach

Declare a 32-bit modular type, a constant A of 42, a constant B computed as not A + 1, and a Boolean constant testing A + B = 0. Then use an if statement to print a literal line reporting the result with Silver_IO.Put_Line. There are no loops, no input and no guards needed. About 14 lines.

## Language surface beyond today's Silver

Modular types and Boolean objects.

## External effects

- **console output** (allowed): Prints a line stating whether the computed two's complement negates the original value.

Assessed on 2026-10-15 against page revision 411940 of the [task](https://rosettacode.org/wiki/Two's_complement) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
