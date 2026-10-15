# Special characters

**Candidate: proofs likely to discharge automatically.** The program is just a series of Put_Line calls on static String literals, and doubled quotes inside them are ordinary Ada that Silver already admits. Those calls have no run-time checks beyond routine ones, so its proofs should discharge trivially with what Silver supports today.

Position 19 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

A parameterless Main prints fixed String literals with Silver_IO.Put_Line that list Ada's special characters, its compound delimiters and the identifier rule. It then shows that the doubled quotation mark is the only escape sequence, printing a literal such as "Quote """"'""""" (shown as Quote "'"). It needs no variables, loops or guards. About 16 lines.

## External effects

- **console output** (allowed): The program prints the list of special characters and an escape-sequence demonstration with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415322 of the [task](https://rosettacode.org/wiki/Special_characters) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
