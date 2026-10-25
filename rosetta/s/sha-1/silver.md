# SHA-1

**Candidate: proofs likely to discharge automatically.** Every operation is wraparound arithmetic on a modular type, static-bound array indexing in for loops and masked table lookups, so all checks follow from types and loop ranges with no loop-carried guard needed. The single-block fixed message is a documented resource limit that keeps the program faithful to the digest of the task's example string.

Position 1277 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

The program hashes an embedded message such as "Rosetta Code" (shorter than 56 bytes, so exactly one 512-bit block) using a 32-bit modular word type, a 16-word block array, an 80-word schedule array and five working variables updated in a for loop over 0..79 with a case on round range for F and K. The padding step copies Character'Pos values into big-endian words, appends the 16#80# byte and the bit length, with all indexes driven by for-loop ranges over static array bounds. The five result words are rendered to a 40-character String through a constant hex-digit table indexed by masked shifts and printed with Put_Line. About 90 lines.

## Proof obligations to watch

- **index**: Message-schedule accesses such as W(T-3) occur in for loops over 16..79 and padded-block writes use for loops over static ranges, so the provers see the bounds from loop ranges without invariants.
- **range**: Hex-digit lookup uses Shift_Right and a mask of 15 on a 32-bit modular word, then converts to an index subtype of 0..15, which the provers discharge from the mask bound.
- **overflow**: All round arithmetic is in a modular type where addition wraps by definition, so no overflow check arises; conversions from Character'Pos (0..255) into the word type are statically in range.

## Language surface recorded by this assessment

Modular types, ranged subtypes, characters, arrays, for loops, string indexing, string building, integers, procedures, functions and case statements.

## External effects

- **console output** (allowed): The program prints the label and the 40-character hex digest with Put_Line.

Assessed on 2026-10-15 against page revision 415169 of the [task](https://rosettacode.org/wiki/SHA-1) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
