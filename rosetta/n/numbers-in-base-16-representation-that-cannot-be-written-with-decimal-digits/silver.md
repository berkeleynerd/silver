# Numbers in base-16 representation that cannot be written with decimal digits

**Candidate: proofs likely to discharge automatically.** All arithmetic is on small ranged integers with constant bounds (n < 500, at most 3 hex digits), so every check follows from types and guards just before use, and the digit-extraction loop lives in a procedure so it needs no termination proof.

Position 449 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Loop over N in 1 .. 499 in the main procedure; a helper procedure copies N into a local, extracts hex digits with mod 16 and / 16 in a bounded while loop (at most 3 digits, guarded by an index check), and sets a flag false if any digit is below 10. Qualifying numbers are printed with a decimal image and a hex string built from a Character lookup into a constant 16-character table, and a final count line is printed. About 55 lines.

## Proof obligations to watch

- **index**: Hex digit buffer writes use a position that decreases in a while loop, so a guard before each write (position >= 1) is needed, and the buffer is sized for 3 digits to cover the 499 limit.
- **overflow**: The count is a loop-carried value, discharged by declaring it as a subtype ranged 0 .. 499 and incrementing it only inside the 1 .. 499 for loop, or by guarding it before increment.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string building, 'Image of scalars, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints each qualifying number with its hex form and a final count.

Assessed on 2026-10-15 against page revision 408075 of the [task](https://rosettacode.org/wiki/Numbers_in_base-16_representation_that_cannot_be_written_with_decimal_digits) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
