# User input/Text

**Candidate: proofs likely to discharge automatically.** The task is plain console input of a string and an integer, and with an admitted bounded line reader and validating integer parser every check is a type or guard, so no annotation is needed.

Position 1216 in the [progression](../../../progression.md#stage-21), in stage 21.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

A procedure Main prints a prompt with Put, reads one line into a fixed-capacity bounded buffer through an admitted stdin line operation that returns a status, then prompts again and reads a second line which it parses into a bounded Integer subtype through a validating parse operation. On any read or parse failure it prints a specified rejection message and stops, otherwise it echoes the string and the number (75000 is just a valid input) with Put_Line using the integer-to-text conversion. About 30 lines.

## Proof obligations to watch

- **range**: Parsing the integer line is discharged by an admitted validating parse operation that reports failure, and invalid input is rejected visibly rather than raising Constraint_Error.
- **length**: Input lines longer than the fixed buffer are rejected or reported by the admitted line-reading operation, so the bounded string never overflows.

## Language surface beyond today's Silver

Standard input, text parsing, string building, ranged subtypes, 'Image of scalars, Put without a newline, procedures and Boolean objects.

## External effects

- **standard input** (allowed): The program must read a string and the integer 75000 from the text console.
- **console output** (allowed): Prompts and the echoed string and integer are written to the console.

Assessed on 2026-10-15 against page revision 413109 of the [task](https://rosettacode.org/wiki/User_input/Text) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
