# Multiplication tables

**Candidate: proofs likely to discharge automatically.** Loop indexes are statically bounded 1..12, so the product is at most 144 and every overflow, range and index check follows from types, with no loop-carried state.

Position 513 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Nested for loops over 1..12 compute Row * Column in a subtype range 1..144 and print each cell right-aligned in a width-4 field, using spaces for cells left of the diagonal. A small procedure fills a fixed 4-character String buffer by digit extraction with / and mod, and Put emits it without a line terminator; the header row and dashed separator are built from literals. About 45 lines.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, string indexing, string building, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The table is printed to standard output line by line.

Assessed on 2026-10-15 against page revision 414747 of the [task](https://rosettacode.org/wiki/Multiplication_tables) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
