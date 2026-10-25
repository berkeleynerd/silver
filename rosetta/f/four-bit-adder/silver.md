# Four bit adder

**Candidate: proofs likely to discharge automatically.** Everything is Boolean logic on constant-index array elements with fixed-length string output, so no overflow, range or termination obligation can arise and all checks follow from static bounds and for-loop ranges.

Position 770 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Represent a four-bit number as a constrained array (1..4) of Boolean, with Boolean procedures for Half_Adder and Full_Adder wired exactly as the task describes (xor built from not/and/or), and a Four_Bits_Adder procedure that chains four full adders from the low bit with a carry. A function maps a Boolean to the Character '0' or '1', and a small number of embedded test pairs (or nested for loops over Boolean) are added and printed as fixed-length strings built by concatenating the characters, e.g. "0101 + 0011 = 1000 0". About 70 lines.

## Language surface recorded by this assessment

Boolean objects, characters, arrays, for loops, procedures, functions, string building, Put without a newline, case statements, integers and ranged subtypes.

## External effects

- **console output** (allowed): Prints each test sum of two four-bit numbers in binary with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 414220 of the [task](https://rosettacode.org/wiki/Four_bit_adder) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
