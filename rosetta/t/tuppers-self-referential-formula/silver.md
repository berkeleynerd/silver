# Tupper's self-referential formula

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged digit and bit subtypes, for-loop indexes over static bounds and a guard before each remainder update, and no annotation is needed because all loops are for loops in procedures. It is plausible rather than likely because fixed-capacity big-number arithmetic with loop-carried carries and remainders is carried through nested loops.

Position 1364 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Embed k as a constant array of about 543 decimal digits (subtype 0..9), convert it to a 1802-element bit array by repeated halving with for loops, then bit-serially divide by 17 (remainder subtype 0..33, subtract 17 when at least 17) to get floor(k/17), reading y mod 17 as the row since k is a multiple of 17. For each of the 17 rows, build a 106-character String by testing bit 17*column+row of the quotient and writing a block or space character, then print each row with Put_Line. About 95 lines.

## Proof obligations to watch

- **overflow**: The digit halving and bit-serial division carry values (carry 0..1, remainder 0..33) through loops without invariants, so each is a small ranged subtype and a guard subtracts 17 before the remainder is stored, which bounds every intermediate.
- **index**: Bit position 17*column+row is computed from for-loop indexes with static ranges (at most 1801), so it fits the 1802-bit array bound by types, though this is nonlinear-looking arithmetic the provers must bound.
- **range**: Each halving pass must reduce a 543-digit decimal array in place with a carry that stays a digit, which holds only if the digit elements are a 0..9 subtype and the 10*carry+digit expression is bounded by types.
- **termination**: All loops are for loops inside procedures, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, for loops, procedures, big numbers, string building, string indexing and Put without a newline.

## External effects

- **console output** (allowed): The 17 rows of 106 characters are printed as text art.

Assessed on 2026-10-15 against page revision 414989 of the [task](https://rosettacode.org/wiki/Tupper's_self-referential_formula) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
