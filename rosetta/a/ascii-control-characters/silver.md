# ASCII control characters

**Candidate: proofs likely to discharge automatically.** Everything is a static enumeration walked by a for loop with a small ranged code value, so all checks follow from types and static bounds with no loop-carried state. Only the string-length check on the printed line needs care.

Position 1145 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Declare an enumeration type with the 32 control names, SP and DEL, and loop over it with a for loop in the Main procedure. For each literal compute its ASCII code as 'Pos, or 127 for DEL, in a 0..127 subtype, then print the 'Image name and the integer image joined by bounded concatenation. Lookup by name is the enumeration literal itself, so no input handling is needed. About 30 lines.

## Proof obligations to watch

- **length**: The concatenation of a name image, separator and code image must fit the bounded String limit, which holds because the enumeration images and a 0..127 code subtype have small static maximum lengths.

## Language surface recorded by this assessment

Enumerations, for loops, 'Image of scalars, integers and ranged subtypes.

## External effects

- **console output** (allowed): The program prints each control character name with its ASCII code, one per line.

Assessed on 2026-10-15 against page revision 404445 of the [task](https://rosettacode.org/wiki/ASCII_control_characters) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
