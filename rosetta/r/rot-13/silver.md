# Rot-13

**Candidate: proofs likely to discharge automatically.** Every index is the loop variable over the string's own range, and each Character'Val argument is bounded by the guard on the character just before the shift, so no loop-carried value needs an invariant. Rot-13 is a pure per-character mapping, so there is no recursion, while loop or accumulator.

Position 485 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed a sample sentence as a fixed-length String constant, copy it into a same-length String variable, and use a for loop over the index range to replace each Character by index. Each character is classified with if/elsif comparisons ('a'..'m', 'n'..'z', 'A'..'M', 'N'..'Z') and shifted by plus or minus 13 using Character'Pos and Character'Val, leaving every other character unchanged. The result is printed, then the transform is applied again to show it round-trips; the optional file/stdin filter wrapper is left out. About 28 lines.

## Language surface beyond today's Silver

Characters, string indexing, for loops, integers and ranged subtypes.

## External effects

- **console output** (allowed): The encoded text, and the decoded round trip, are written with Put_Line.

Assessed on 2026-10-15 against page revision 414888 of the [task](https://rosettacode.org/wiki/Rot-13) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
