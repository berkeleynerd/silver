# Roman numerals/Encode

**Candidate: proofs plausibly discharge automatically.** All checks follow from the Number subtype range, constant tables and a capacity guard before each append, with the while loop confined to a procedure, but the loop-carried position and remaining value make discharge depend on careful program shape.

Position 994 in the [progression](../../../progression.md#stage-16), in stage 16.

## Approach

A procedure takes a Number of subtype 1..3999 and fills a fixed 15-character buffer plus a length, walking a constant 13-entry table of values (1000, 900, ... 1) with parallel constant symbol characters, using a while loop that appends the symbol(s) while the remaining value is at least the table value. Each append is guarded by a capacity check that sets a failure flag instead of truncating, and the main program calls the procedure for the embedded examples 1990, 2008 and 1666 and prints the slice of the buffer, or a rejection message if the flag is set. About 55 lines.

## Proof obligations to watch

- **index**: The write position into the 15-character buffer is loop-carried, so each append is preceded by an explicit check that the position is within capacity, with overflow leading to a visible rejection.
- **overflow**: The remaining value and position are bounded by their subtype ranges and the remaining value only decreases by table entries, so subtraction stays in range.
- **termination**: The subtracting while loop sits in a procedure, which gets no termination check, so no variant is needed.
- **length**: The output slice from index 1 to the final length is guarded by the same capacity check so Put_Line receives a valid slice.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, for loops, while loops, procedures and unconstrained arrays.

## External effects

- **console output** (allowed): Prints the Roman numeral for each embedded example number with Put_Line.

Assessed on 2026-10-15 against page revision 411580 of the [task](https://rosettacode.org/wiki/Roman_numerals/Encode) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
