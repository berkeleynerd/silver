# Integer long division

**Candidate: proofs plausibly discharge automatically.** All indices and arithmetic are bounded by ranged subtypes and a capacity guard in the while-loop condition, and the loop lives in a procedure so no termination variant is needed; the arithmetic is only small integer mod/div by a constant, so the proofs should discharge with careful program shape.

Position 997 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Embed numerator 1 and denominator 149 as constants and run a procedure with a while loop that records, for each remainder (a ranged subtype 0 .. 148), the position where it first appeared in a fixed seen-position array while appending the next digit character to a bounded digit buffer, stopping when a remainder repeats or the remainder becomes 0. The loop condition guards the buffer capacity, and the period is the digit count minus the stored first-seen position (0 when the remainder reached 0). A second pass copies the integer part, the pre-period digits and the repeating block in braces into a bounded text buffer and prints it and the period via Put_Line with Integer'Image. About 70 lines.

## Proof obligations to watch

- **index**: The digit buffer and seen-remainder table are indexed by a loop-carried count and remainder, so the while condition requires count below the buffer capacity and the remainder is typed as a range 0 .. 148, making each index check follow from the loop guard and subtype.
- **overflow**: The remainder times 10 and the position counter are bounded by their declared subtypes (remainder below 149, position at most the capacity), so no loop invariant is needed.
- **range**: Assigning r*10 mod 149 back to a ranged remainder subtype and converting a digit 0..9 to Character via 'Val relies on solver reasoning about mod and division by constants, which should discharge without an invariant.
- **length**: Assembling the output text in a fixed buffer with a computed fill index needs a guard before each append so the index never exceeds the buffer length.
- **other**: Repeat detection through the seen table ends the loop by pigeonhole, which only a procedure (no termination check) allows, and the explicit capacity guard gives a visible outcome (reject) if a denominator ever exceeded the buffer.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, unconstrained arrays, string indexing, string building, 'Image of scalars, for loops, while loops, procedures and conditional expressions.

## External effects

- **console output** (allowed): Prints the decimal expansion with the repeating block marked and the period length via Put_Line.

Assessed on 2026-10-15 against page revision 393233 of the [task](https://rosettacode.org/wiki/Integer_long_division) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
