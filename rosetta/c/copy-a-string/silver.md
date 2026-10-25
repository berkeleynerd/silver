# Copy a string

**Candidate: proofs likely to discharge automatically.** Today's Silver already covers this program (String constants, equal-length fixed String assignment and Put_Line), and its only check is a static length check that the declared lengths settle, so it should prove automatically.

Position 20 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

A Main procedure declares a String constant Src ("Hello") and a fixed-length String variable Dest of the same length, assigns Dest := Src to copy the contents, then overwrites Dest with another equal-length literal and prints both to show the source is unaffected. Ada value semantics make every String assignment a content copy, so the "additional reference" case does not apply without access types, which the task only asks to distinguish "where relevant". About 15 lines.

## External effects

- **console output** (allowed): The program prints the source and the copied string with Silver_IO.Put_Line to show the copy holds the same contents.

Assessed on 2026-10-15 against page revision 415285 of the [task](https://rosettacode.org/wiki/Copy_a_string) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
