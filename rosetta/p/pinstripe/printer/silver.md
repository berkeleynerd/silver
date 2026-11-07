# Pinstripe/Printer

**Candidate: proofs likely to discharge automatically.** Every index, division and arithmetic check follows from for-loop ranges and constant bounds (the divisor is a stripe width of at least 1 by its subtype), and nothing is loop-carried, so no annotation is needed.

Position 498 in the [progression](../../../progression.md#stage-10), in stage 10.

## Approach

A fixed-width String row buffer is filled by an outer for loop over stripe widths 1 to 11 (a ranged subtype) and an inner for loop over the column index 1 to Width, choosing a white or black character by ((column - 1) / stripe width) mod 2. Each band prints a fixed number of identical rows with Put_Line, standing in for one inch, so the whole test card is produced in order with no input or guards needed. A small procedure builds and prints one row from the stripe width. About 40 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, string indexing, string building, for loops and procedures.

## External effects

- **console output** (allowed): The pinstripe test card is drawn as text art lines written to standard output, which the task allows in place of a printer.

Assessed on 2026-10-15 against page revision 414820 of the [task](https://rosettacode.org/wiki/Pinstripe/Printer) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
