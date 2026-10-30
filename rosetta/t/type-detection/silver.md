# Type detection

**Candidate: proofs likely to discharge automatically.** The task is a tagged-dispatch print demo with no arithmetic, loops or recursion, so every check is trivially routine and no annotation is needed. It only requires enumerations, case statements and a procedure with a String parameter beyond today's Silver.

Position 1144 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

A tag enumeration (Literal_Text, Buffer_Text) describes the source, and a procedure Process_Text takes the tag plus a String and uses a case statement on the tag to print a source label and then the text via Put_Line. Main calls it twice, once with a String literal tagged Literal_Text and once with a fixed-length String variable tagged Buffer_Text, with no loops, arithmetic or indexing. About 30 lines.

## Language surface recorded by this assessment

Enumerations, case statements, procedures, unconstrained arrays and 'Image of scalars.

## External effects

- **console output** (allowed): The procedure prints each block of text with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415523 of the [task](https://rosettacode.org/wiki/Type_detection) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
