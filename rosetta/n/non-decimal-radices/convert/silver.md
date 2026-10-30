# Non-decimal radices/Convert

**Candidate: proofs likely to discharge automatically.** All checks follow from the Base subtype, a for loop over the buffer's own range, and one overflow guard on the accumulator, so no annotation is needed.

Position 1119 in the [progression](../../../progression.md#stage-18), in stage 18.

## Approach

Base is a subtype range 2..36 and the digits come from a constant String "0123456789abcdefghijklmnopqrstuvwxyz". To_Base is a procedure that fills a fixed 32-character buffer from the end with a for loop, writing Temp mod Base when Temp > 0 and dividing Temp by Base, then emits the used slice (or "0" for zero). To_Decimal scans the digit table with a for loop for each character, rejects invalid digits and overflow with a visible Reject outcome, and the main procedure converts the embedded 26 in base 16 to "1a" and "1a" back to 26. About 70 lines.

## Proof obligations to watch

- **overflow**: The accumulator Result*Base+Digit is loop-carried, so a guard just before the update rejects the input unless Result <= (Natural'Last - Digit) / Base, giving invalid input a visible outcome.
- **index**: To_Base fills a 32-character buffer from the end with a for loop over its own range, guarded by Temp > 0, so the index is the loop variable and needs no invariant (a Natural has at most 31 binary digits).
- **range**: Digit values come from a bounded scan of the 36-character digit table and are checked against Base before use, so they stay in 0..35.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, string indexing, string building, 'Image of scalars, text parsing, for loops, while loops, procedures, functions, Boolean objects and conditional expressions.

## External effects

- **console output** (allowed): Prints the converted string and the parsed integer with Put_Line.

Assessed on 2026-10-15 against page revision 413802 of the [task](https://rosettacode.org/wiki/Non-decimal_radices/Convert) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
