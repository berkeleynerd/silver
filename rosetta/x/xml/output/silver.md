# XML/Output

**Candidate: proofs plausibly discharge automatically.** Every check follows from array bounds, a bounded length subtype and a guard before each append, with no while loops or recursion, though the loop-carried output length needs careful guarding.

Position 1001 in the [progression](../../../progression.md#stage-16), in stage 16.

## Approach

A procedure Escape_Text copies an input String into a fixed-size Character buffer, replacing the five XML entity characters (&, <, >, " and ') with their entity strings, using a for loop over the input's range and a case statement. A procedure Emit_Character takes a name and a remark, escapes both, and prints one Character element line with Put_Line. Main prints the CharacterRemarks opening tag, calls Emit_Character for the three embedded name/remark pairs, then prints the closing tag. About 70 lines.

## Proof obligations to watch

- **index**: Writing escaped text into a fixed buffer uses a loop-carried length, so each append is preceded by an explicit capacity guard and the buffer is sized at six times the longest input.
- **range**: The loop-carried length is declared with a subtype bounded by the buffer capacity and checked against remaining room before each increment, with overflow giving a visible rejection message rather than truncation.
- **length**: Printing the escaped slice Buffer (1 .. Length) needs Length to be known within the buffer bounds, which its declared subtype provides.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing, string building, unconstrained arrays, for loops, case statements, procedures and Put without a newline.

## External effects

- **console output** (allowed): The XML document is printed line by line to standard output.

Assessed on 2026-10-15 against page revision 414592 of the [task](https://rosettacode.org/wiki/XML/Output) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
