# Colour bars/Display

**Candidate: proofs likely to discharge automatically.** Everything is constant text printed in a bounded for loop, so no check can fail and no loop-carried value exists.

Position 32 in the [progression](../../../progression.md#stage-2), in stage 2, which adds for loops and integers.

## Approach

The program builds one constant 80-character row made of eight 10-character bars, each filled with its own character and labelled with its colour (BLACK, RED, GREEN, BLUE, MAGENTA, CYAN, YELLOW, WHITE) via fixed-length String constants and concatenation. A for loop over a literal range of 1 to 8 prints that row eight times with Put_Line to give the bars height, so there is no input and no guard is needed. About 25 lines.

## Language surface beyond today's Silver

For loops and integers.

## External effects

- **console output** (allowed): The bars are drawn as text art lines on standard output, which meets the task without a window or display.

Assessed on 2026-10-15 against page revision 415034 of the [task](https://rosettacode.org/wiki/Colour_bars/Display) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
