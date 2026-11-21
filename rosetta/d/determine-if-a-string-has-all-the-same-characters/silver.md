# Determine if a string has all the same characters

**Candidate: proofs likely to discharge automatically.** Every check derives from the string's own index range and a 0..255 character position, with no loop-carried arithmetic beyond a Natural index, so it should discharge without annotations. Silver just needs strings with indexing, for loops, procedures, and Put plus 'Image output.

Position 772 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

A procedure takes a String parameter and scans with a for loop from S'First+1 to S'Last, recording the first index differing from S(S'First) in a Natural and exiting via a guard-free flag-controlled loop shape. It prints the string and length with Put_Line, then either the all-same message or the position, the character, and its hexadecimal value computed by dividing Character'Pos by 16 and mod 16 into two hex digit characters via a small constant lookup string. The seven embedded test strings are called from Main. About 70 lines.

## Proof obligations to watch

- **index**: Loop index runs over the string's own range from First+1 to Last and element 'First is read only when the loop executes, so checks discharge.
- **length**: Output lines are built in a bounded buffer sized for the longest test string plus fixed message text, so concatenation lengths are static bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, 'Image of scalars, case statements, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints each test string, its length, and the same/different message with position and hex value.

Assessed on 2026-10-15 against page revision 415397 of the [task](https://rosettacode.org/wiki/Determine_if_a_string_has_all_the_same_characters) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
