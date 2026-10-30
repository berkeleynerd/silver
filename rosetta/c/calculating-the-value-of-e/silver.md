# Calculating the value of e

**Candidate: proofs plausibly discharge automatically.** Integer fixed-point series over a bounded for loop keeps every operand within declared ranges, so all checks follow from types and one guard, giving a plausible outlook; floating point is avoided since the task only asks for the value of e, not a specific method.

Position 534 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Compute e as a fixed-point integer scaled by 10**15 using the series sum of 1/k!, with a term variable divided by the for-loop index k (1..20) and added to a sum guarded by a declared bound. Then split the sum into integer part and 15 fraction digits, filling a fixed-length String buffer with a for loop using mod and div by 10, and print "e = " plus the digits via Put_Line concatenation. No floating point, recursion or while loops are used. About 35 lines.

## Proof obligations to watch

- **overflow**: The scaled sum is loop-carried, so a guard against a declared bound just before each addition is needed to make the add and the range check provable.
- **range**: The term shrinks each iteration but the prover only knows its subtype range, so division by the positive loop index is assigned back into the same subtype, which is routine.
- **index**: Digit extraction into a fixed 15-character buffer uses a for loop over the buffer's own range with the remainder converted to a character via 'Val on a 0..9 value, which discharges from the mod bound.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, string indexing, string building, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The program prints the computed value of e as a line of text.

Assessed on 2026-10-15 against page revision 415299 of the [task](https://rosettacode.org/wiki/Calculating_the_value_of_e) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
