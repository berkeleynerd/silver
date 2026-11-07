# Colour pinstripe/Display

**Candidate: proofs likely to discharge automatically.** Text art meets the display requirement, and every check follows from for-loop ranges and the mod 8 palette index, so no loop-carried value needs an invariant.

Position 483 in the [progression](../../../progression.md#stage-10), in stage 10.

## Approach

A constant palette string "KRGBMCYW" (black, red, green, blue, magenta, cyan, yellow, white) and a fixed 64-character line buffer stand in for the display width. A for loop over the four bands (stripe width equal to the band number) fills the buffer by looping over Line'Range, setting each character to Palette ((X - 1) / Band mod 8 + 1), and then prints the line for each of a few rows in that band with Put_Line. Every index is bounded by the mod 8 expression, the loop ranges and the constant buffer length. About 30 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, string indexing, string building, for loops and procedures.

## External effects

- **console output** (allowed): The stripes are rendered as text art, one Put_Line per display row, with a letter standing for each colour.

Assessed on 2026-10-15 against page revision 415364 of the [task](https://rosettacode.org/wiki/Colour_pinstripe/Display) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
