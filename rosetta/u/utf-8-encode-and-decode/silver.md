# UTF-8 encode and decode

**Candidate: proofs likely to discharge automatically.** Everything is bounded integer arithmetic with for loops and guards, and the invalid cases (surrogates, over-range values, malformed bytes) have a visible rejected outcome, so each check follows from subtypes and guards. Non-ASCII characters can be shown as the code point and hex bytes, so no wide text output is required.

Position 1288 in the [progression](../../progression.md#stage-22), in stage 22.

## Approach

The program embeds the five code points as an array of integers in a subtype 0 .. 16#10FFFF#. An Encode procedure fills a 4-byte array and a length using if branches on the 1, 2, 3 and 4-byte ranges. A Decode procedure validates the lead and continuation byte patterns and reports invalid input with a Boolean out parameter, and a for loop prints each code point, its hex bytes and the round-trip result with Put_Line and Put. About 110 lines.

## Proof obligations to watch

- **range**: Code points are held in a subtype 0 .. 16#10FFFF# and each byte in a 0 .. 255 subtype, with encode branches guarded by explicit range comparisons so every arithmetic result stays in its subtype.
- **index**: The byte buffer is a fixed Byte_Array (1 .. 4) with a Length in 0 .. 4, and the decoder checks that length before indexing.
- **overflow**: Shifts are written as division and multiplication by constants on bounded subtypes, so the results are provably within the byte and code point ranges.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, modular types, Boolean objects, characters, arrays, for loops, case statements, procedures, functions, string indexing, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints a table of characters, code points and UTF-8 hex bytes, plus decode results.

Assessed on 2026-10-15 against page revision 411941 of the [task](https://rosettacode.org/wiki/UTF-8_encode_and_decode) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
