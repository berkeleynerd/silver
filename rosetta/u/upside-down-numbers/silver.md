# Upside-down numbers

**Candidate: proofs plausibly discharge automatically.** Every check follows from small fixed bounds and digit subtypes, but loop-carried block counts, quotients and string buffer positions each need a guard placed just before use, so discharge depends on careful program shape rather than being routine. No annotation is needed since the work is done in procedures with for loops.

Position 820 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Treat the 1st, 2nd, ... Nth number as a selection by length (counts 1, 9, 9, 81, ... up to 8 digits, covering 5000) and then fill an array of at most 8 digits (subtype 1..9) pair by pair, with the mirror digit 10 - d placed at the opposite end and a 5 in the centre of odd lengths. A procedure takes N (guarded to 1..8200 with a visible reject otherwise) and returns the digit array and length; a second procedure copies the digits into a bounded String buffer for Put_Line. The main program loops 1..50 building one comma-separated line, then prints the 500th and 5000th; the stretch targets (millions, 14 digits) are optional and are omitted. About 90 lines.

## Proof obligations to watch

- **range**: Loop-carried remainders and digit choices (k, count, digit in 1..9) lose bounds after the first iteration, so each is clamped by a guard that rejects out-of-range values visibly, or avoided by an odometer over fixed Digit-typed arrays.
- **division**: Dividing by a loop-carried block count needs a guard that the count is nonzero immediately before the division.
- **index**: Building the output line in a bounded buffer needs a guard on the write position before each character is stored.
- **overflow**: Values up to 56546545 fit in Integer, but the accumulated value in a loop needs a type range or guard to bound it.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, for loops, procedures, string building and case statements.

## External effects

- **console output** (allowed): Prints the first 50 numbers and the 500th and 5000th upside-down numbers as text lines.

Assessed on 2026-10-15 against page revision 414566 of the [task](https://rosettacode.org/wiki/Upside-down_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
