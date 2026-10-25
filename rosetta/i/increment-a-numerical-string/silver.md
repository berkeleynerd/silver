# Increment a numerical string

**Candidate: proofs likely to discharge automatically.** Every check comes from fixed string bounds, a Boolean carry and a digit guard placed just before each character arithmetic step, so no loop invariant is needed. The program avoids Integer'Value, which would raise on bad text, and uses digit-wise increment instead.

Position 487 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The numeric string "12345" is a fixed 5-character String constant copied into a 6-character result buffer, and a reverse for loop over its indexes adds one with a Boolean carry, turning '9' into '0' and otherwise stepping the digit. A leading-digit overflow such as "99999" is handled by writing '1' into the extra leading slot; a non-digit character takes a visible rejection branch that prints a message. The result is printed with Put_Line after trimming a leading blank. About 35 lines.

## Proof obligations to watch

- **range**: Character'Val(Character'Pos(C)+1) is only evaluated after an explicit guard that C is between '0' and '8', so the result stays a digit and the check discharges.
- **index**: Loop indexes run over the string's own fixed range and the result buffer is one character longer, so every index follows from static bounds.

## Language surface recorded by this assessment

Characters, string indexing, string building, for loops, Boolean objects and integers.

## External effects

- **console output** (allowed): The incremented numeric string is written with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 412844 of the [task](https://rosettacode.org/wiki/Increment_a_numerical_string) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
