# Loops/Downward for

**Candidate: proofs likely to discharge automatically.** The loop has static bounds, so it terminates by construction, and the loop index lies in a small known range, so Integer'Image cannot fail a length or range check. The only new surface is for loops over a reverse range and integer-to-text conversion.

Position 63 in the [progression](../../../progression.md#stage-7), in stage 7.

## Approach

The program is a parameterless Main procedure with pragma SPARK_Mode (On) containing a single for loop over reverse 0 .. 10, whose loop index is an Integer. Each iteration converts the index to text with Integer'Image, trims the leading space, and writes it with Silver_IO.Put_Line. The loop bounds are static and no guards are needed. About 8 lines.

## Language surface beyond today's Silver

Integers, ranged subtypes, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The countdown values 10 down to 0 are written to standard output, one per line.

Assessed on 2026-10-15 against page revision 412893 of the [task](https://rosettacode.org/wiki/Loops/Downward_for) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
