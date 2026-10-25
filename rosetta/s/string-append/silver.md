# String append

**Candidate: proofs likely to discharge automatically.** The task is one in-place append of a literal followed by one print, so every index and length check follows from a fixed buffer capacity and a guard just before the copy. Today's Silver only has fixed-length strings with bounded concatenation, so a bounded string buffer with an in-place append is the only missing piece.

Position 65 in the [progression](../../progression.md#stage-4), in stage 4, which adds string building.

## Approach

Keep the text in a bounded buffer with a length counter: declare a Str buffer, a Len counter, and a literal to append. Guard on the length (Len plus the literal's length does not exceed the capacity), then copy the literal's characters into the buffer and print the first Len characters; if the guard fails, print a specified rejection message. Because the buffer's capacity is fixed and the guard precedes the copy, no index or length check can fail. About 12 lines.

## Language surface recorded by this assessment

String building and procedures.

## External effects

- **console output** (allowed): The program prints the string after the append with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413057 of the [task](https://rosettacode.org/wiki/String_append) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
