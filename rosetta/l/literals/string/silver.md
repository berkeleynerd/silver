# Literals/String

**Candidate: proofs likely to discharge automatically.** The only checks are static-length concatenations and assignments of literals to constants, which GNATprove discharges trivially, so proof is likely. The only addition beyond today's Silver is a Character constant built from a character literal and concatenated onto a String for output.

Position 436 in the [progression](../../../progression.md#stage-10), in stage 10.

## Approach

Main declares a Character constant from a character literal ('a' and the quote character '''), String constants from literals including the empty string and a literal with doubled quotes (""), and prints each, concatenating the Character onto a String literal for output. There are no loops, no input and no guards; because Ada has no verbatim strings, here-strings or variable interpolation, the program simply shows that the fixed literals print exactly as written. About 20 lines.

## Language surface recorded by this assessment

Characters.

## External effects

- **console output** (allowed): The program prints the literal values it declares with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415263 of the [task](https://rosettacode.org/wiki/Literals/String) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
