# Hello world/Newline omission

**Candidate: proofs likely to discharge automatically.** The program is a single call to a newline-free output operation on a constant string, so every check is trivial; the only missing piece is Silver_IO.Put, which Silver does not have yet.

Position 62 in the [progression](../../../progression.md#stage-7), in stage 7, which adds Put without a newline.

## Approach

A parameterless Main procedure with pragma SPARK_Mode (On) calls Silver_IO.Put with the literal "Goodbye, World!". There is no data, loop or guard, so no proof obligation arises beyond the admitted library operation's contract. About 6 lines.

## Language surface beyond today's Silver

Put without a newline.

## External effects

- **console output** (allowed): Writes Goodbye, World! to standard output with no line terminator.

Assessed on 2026-10-15 against page revision 411522 of the [task](https://rosettacode.org/wiki/Hello_world/Newline_omission) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
