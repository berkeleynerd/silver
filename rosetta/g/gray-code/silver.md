# Gray code

**Candidate: proofs likely to discharge automatically.** All arithmetic is on a wraparound 5-bit modular type with only for loops over static ranges and fixed-size strings indexed by loop variables over their own range, so every check follows from types and no annotation is needed.

Position 1263 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Declare a 5-bit modular type (mod 32); Encode returns B xor (B / 2) and Decode is a for loop of five steps folding the successively halved Gray value into the result with xor, so no overflow or range check can arise. A for loop over 0 .. 31 converts each value to a fixed 5-character String by assigning bit characters at constant-range indexes, then prints one line of the three binary strings or numbers per iteration via Put_Line and 'Image. About 45 lines.

## Language surface recorded by this assessment

Modular types, integer division, integers, ranged subtypes, characters, string indexing, string building, 'Image of scalars, for loops, functions and procedures.

## External effects

- **console output** (allowed): Prints a table of 32 lines of binary, Gray and decoded values with Put_Line.

Assessed on 2026-10-15 against page revision 415507 of the [task](https://rosettacode.org/wiki/Gray_code) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
