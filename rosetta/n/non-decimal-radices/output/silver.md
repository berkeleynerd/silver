# Non-decimal radices/Output

**Candidate: proofs likely to discharge automatically.** All values are tiny (1..33) with fixed-size buffers and bases, so every index and range check follows from types and loop guards, with no function termination issues because the while loop lives in a procedure.

Position 443 in the [progression](../../../progression.md#stage-9), in stage 9.

## Approach

Define a procedure Format_Radix that writes a value (range 0..255) in a given base (8 or 16) into a fixed 8-character buffer, filling digits right to left with mod and / in a while loop guarded by index > 0 and value > 0, using a digit-lookup constant String "0123456789ABCDEF". The main for loop over 1..33 builds each line by concatenating space-padded decimal, hex and octal fields in a bounded buffer and calls Put_Line, emitting plain digits (no Ada 16#..# notation) since the task only asks to print numbers in different bases. About 45 lines.

## Proof obligations to watch

- **index**: Digit extraction fills a fixed 8-character buffer with an index decremented in a while loop, discharged by a guard in the loop condition (position > 0) and a small value range for 1..33.
- **range**: Digit values come from value mod Base with Base fixed at 8 or 16, so Character'Val of a digit offset stays within a small bounded range.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string building, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints a table of integers 1..33 in decimal, hexadecimal and octal to standard output.

Assessed on 2026-10-15 against page revision 414901 of the [task](https://rosettacode.org/wiki/Non-decimal_radices/Output) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
