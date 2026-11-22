# Base64 decode data

**Candidate: proofs likely to discharge automatically.** Every check follows from the 0..63 value subtype, for-loop indexes over groups of a length-checked input, and a guarded fixed buffer, with no loop-carried accumulator wider than its type. The task needs nothing an annotation would supply, and the only dependence is careful program shape around padding and index arithmetic.

Position 769 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The program embeds the encoded sample as a String constant and defines a procedure that checks the length is a multiple of four and that padding appears only at the end. It then runs a for loop over the groups, mapping each of the four characters to a 0..63 value, computing up to three bytes with integer division and mod, and storing them as Characters in a fixed buffer with a count. It prints the encoded input and the decoded prefix, and on any invalid character or bad padding it prints a specified rejection message instead of output. About 70 lines.

## Proof obligations to watch

- **index**: Each 4-character group is read at indexes computed from the for-loop variable over a length that is checked to be a multiple of four, and output positions are guarded against buffer capacity before each write.
- **range**: Each Base64 character maps through a case or if chain to a 0..63 subtype or an invalid flag, so the byte arithmetic (v1*4 + v2/16, and so on) stays within 0..255 by type ranges and Character'Val is only applied to a value already in range.
- **length**: The decoded output goes into a fixed-capacity buffer sized for at most three quarters of the input length, and the final Put_Line prints only the filled prefix, so no slice can exceed bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, for loops, procedures, functions and case statements.

## External effects

- **console output** (allowed): The decoded text is printed with Put_Line.

Assessed on 2026-10-15 against page revision 413650 of the [task](https://rosettacode.org/wiki/Base64_decode_data) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
