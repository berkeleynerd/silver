# Show ASCII table

**Candidate: proofs likely to discharge automatically.** All loops are for loops over constant ranges with no loop-carried state beyond the freshly rewritten row buffer, so every index, range and division check follows from the types and the loop bounds.

Position 494 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Nested for loops over R in 0..15 and C in 0..5 compute N = 32 + 16*C + R in a small integer subtype, and write the three digits of N (via / and mod 10, with a leading-space guard), " : ", and a 5-character label into a fixed 66-character String row buffer. The label is "Spc  " for 32, "Del  " for 127 and the character followed by four spaces otherwise, chosen by if/elsif; each finished row is printed with Put_Line. About 35 lines.

## Proof obligations to watch

- **index**: Buffer positions are computed as 11*C + offset from for-loop indexes over small constant ranges, so the bounds follow from the loop ranges and the 66-character buffer.
- **range**: Character'Val(N) is only applied to N in 33..126 inside an explicit if guard, with 32 and 127 handled as the Spc and Del labels.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, for loops, string indexing and string building.

## External effects

- **console output** (allowed): Prints the 16 table rows with Put_Line.

Assessed on 2026-10-15 against page revision 415105 of the [task](https://rosettacode.org/wiki/Show_ASCII_table) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
