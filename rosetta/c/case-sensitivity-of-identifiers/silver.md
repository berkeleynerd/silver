# Case-sensitivity of identifiers

**Candidate: proofs likely to discharge automatically.** The program uses only constructs Silver already supports (String constant, concatenation, Put_Line), and every check is static, so proofs discharge trivially.

Position 6 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Declare one String constant Dog := "Bernie" and print "There is just one dog named " & DOG & "." through Silver_IO.Put_Line, referring to the identifier in a different letter case to show Ada's case insensitivity. There are no loops, inputs or arithmetic, so only a bounded concatenation of constant-length strings is involved. About 8 lines.

## External effects

- **console output** (allowed): Prints the single result line with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415324 of the [task](https://rosettacode.org/wiki/Case-sensitivity_of_identifiers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
