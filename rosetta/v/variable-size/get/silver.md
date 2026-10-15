# Variable size/Get

**Candidate: proofs likely to discharge automatically.** The program is straight-line code over static constants, so every check follows from static values and nothing needs an annotation. The only new needs are the 'Size attribute, integer division by a literal and 'Image output.

Position 105 in the [progression](../../../progression.md#stage-8), in stage 8, which adds integer division.

## Approach

Declare an Integer variable and constants holding X'Size (bits) and that value divided by the storage unit of 8 (bytes). Print both through 'Image text with Put_Line. There are no loops, and the only guard is that the divisor is a static nonzero literal. About 10 lines.

## Language surface beyond today's Silver

Integers, integer division and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the variable's size in bits and bytes with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 414570 of the [task](https://rosettacode.org/wiki/Variable_size/Get) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
