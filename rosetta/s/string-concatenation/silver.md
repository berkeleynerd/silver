# String concatenation

**Candidate: proofs likely to discharge automatically.** The task needs only String constants, bounded concatenation and Put_Line, all of which Silver already supports, and every check is static, so proofs discharge trivially.

Position 11 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

A parameterless Main declares a String constant S1 := "Hello" and a String constant S2 := S1 & " literal", with fixed lengths known statically. It then prints S1 and S2 with two Silver_IO.Put_Line calls; there are no loops, inputs or guards. About 8 lines.

## External effects

- **console output** (allowed): The program shows the content of both strings with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 414814 of the [task](https://rosettacode.org/wiki/String_concatenation) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
