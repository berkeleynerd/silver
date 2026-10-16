# Luhn test of credit card numbers

**Candidate: proofs likely to discharge automatically.** Every check follows from the for-loop index range, the character guard before digit conversion, and the mod-10 running sum that stays within a small subtype, so no invariant is required and loops sit in a function with only for loops (no termination obligation).

Position 970 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

A function Luhn_Valid(Num : String) returns Boolean by iterating reverse over Num'Range, rejecting any non-digit character with a False result via a flag, and doubling every second digit (reduced by subtracting 9 when over 9) into a mod-10 running sum kept in a 0..9 subtype. A Check procedure prints the number with Put, then a valid or not valid verdict with Put_Line, and Main calls it on the four embedded task numbers (plus optionally one with a non-digit). About 45 lines.

## Proof obligations to watch

- **overflow**: The running sum is a subtype 0..9 updated as (Sum + Digit) mod 10, so Sum + Digit is at most 18 and no overflow or range check depends on a loop invariant.
- **index**: The loop is a reverse for loop over Num'Range, so every Num(P) index follows from the array's own range.
- **range**: Character'Pos(Num(P)) - Character'Pos('0') is guarded by a test that the character lies between '0' and '9' before conversion to a 0..9 digit subtype, with non-digits yielding a specified invalid verdict.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, unconstrained arrays, string indexing, for loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints each embedded test number followed by a valid or not valid verdict.

Assessed on 2026-10-15 against page revision 414317 of the [task](https://rosettacode.org/wiki/Luhn_test_of_credit_card_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
