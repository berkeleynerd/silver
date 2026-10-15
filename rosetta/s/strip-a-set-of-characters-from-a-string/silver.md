# Strip a set of characters from a string

**Candidate: proofs likely to discharge automatically.** All loops are for loops over the constant strings' own ranges, and the only loop-carried value is the output count, which a bounded subtype and an explicit guard keep safe without any annotation.

Position 502 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Embed the example text and the set "aei" as constants, build a Boolean Keep table indexed by Character (all True, then False for each set character), then copy kept characters into a fixed-capacity Character buffer sized to the input length with a guarded count. Print the buffer prefix as a String of computed length via Put_Line, using a procedure for the strip so the output length is returned via an out parameter and the loop-carried index is guarded. About 35 lines.

## Proof obligations to watch

- **index**: The write position Last is a loop-carried counter, so it is declared as a subtype with range 0..Max and guarded by Last < Max before each increment, which discharges index and range checks.

## Language surface beyond today's Silver

Ranged subtypes, characters, arrays, string indexing, string building, for loops, procedures, Boolean objects and integers.

## External effects

- **console output** (allowed): Prints the stripped result line with Put_Line.

Assessed on 2026-10-15 against page revision 414522 of the [task](https://rosettacode.org/wiki/Strip_a_set_of_characters_from_a_string) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
