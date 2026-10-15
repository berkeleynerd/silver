# Here document

**Candidate: proofs likely to discharge automatically.** The program is a fixed sequence of Put_Line calls on literals, which Silver already supports, so there are no run-time checks to prove and no new surface is needed.

Position 13 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

A parameterless Main procedure with SPARK_Mode (On) emits the multi-line text block as a straight sequence of Silver_IO.Put_Line calls on String literals. Leading indentation and doubled quotation marks are preserved inside each literal, so line breaks and whitespace are kept exactly as in a here document. There are no variables, loops or guards. About 12 lines.

## External effects

- **console output** (allowed): Each line of the text block is written with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 411758 of the [task](https://rosettacode.org/wiki/Here_document) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
