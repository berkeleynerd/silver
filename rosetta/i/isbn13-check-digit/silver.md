# ISBN13 check digit

**Candidate: proofs likely to discharge automatically.** All checks follow from the fixed string length, the digit guard before Character'Pos, and the mod-10-reduced sum in a small subtype, so no loop invariant is needed. The loop is a for loop inside a function, which terminates by itself.

Position 503 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The four test codes are embedded as constants of a fixed-length 14-character String subtype, and a Boolean function loops over indexes 1..14 of the constant. It requires a hyphen at position 4, checks each other character is a digit before converting it, applies weight 1 or 3 by digit position parity, and keeps the sum reduced mod 10 in a 0..9 subtype. A procedure prints each code with Good or Bad using bounded concatenation and Put_Line, and any non-digit or misplaced hyphen yields Bad. About 45 lines.

## Proof obligations to watch

- **overflow**: The running sum is a loop-carried value, so it is kept in a 0..9 subtype by reducing mod 10 after each addition, which preserves the final mod-10 result and makes every addition provably in range.
- **range**: The digit value is computed from Character'Pos only after a guard that the character lies between '0' and '9', so it is provably in 0..9.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, string indexing, for loops, procedures and functions.

## External effects

- **console output** (allowed): Prints each embedded ISBN with a Good or Bad verdict line.

Assessed on 2026-10-15 against page revision 411759 of the [task](https://rosettacode.org/wiki/ISBN13_check_digit) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
