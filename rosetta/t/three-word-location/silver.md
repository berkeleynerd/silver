# Three word location

**Candidate: proofs likely to discharge automatically.** Everything is bounded integer arithmetic with static ranges and for loops over fixed buffers, so all checks follow from types and local guards and no annotation is needed. The only extra work is Silver gaining integer division, character and digit-string construction, and parsing.

Position 1124 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Latitude and longitude are embedded as scaled integers (283852 and -815638 in units of 1e-4 degrees), offset to positive values, and combined as lat * 2**22 + lon in a ranged 64-bit integer, then split into 15, 14 and 14 bit indexes by division and mod. Word strings 'W' plus five zero-padded digits are built in fixed 6-character strings with a for loop and printed, computing the word on demand from its index instead of storing a 28126-entry array. The reverse step parses the digits back from each word with a digit guard, recombines the integer, and prints the decimal latitude and longitude with a sign and four fractional digits built by integer arithmetic, avoiding floating point. About 80 lines.

## Proof obligations to watch

- **overflow**: The 43-bit combined value and the multiplications by 2**22 and 2**14 fit in a 64-bit integer type whose range is declared 0 .. 2**43-1, and the subtype ranges of the scaled latitude and longitude bound each product.
- **range**: Converting digits to Character'Val (48 + d) and parsing digits back are safe because d is computed with mod 10 and each parsed character is guarded to lie between '0' and '9' before use.
- **index**: Word and digit buffers are fixed-length strings written by for loops over their own index ranges, so every index check follows from static bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, string indexing, string building, text parsing, for loops, procedures and functions.

## External effects

- **console output** (allowed): The program prints the three words and the recovered latitude and longitude with Put_Line.

Assessed on 2026-10-15 against page revision 405582 of the [task](https://rosettacode.org/wiki/Three_word_location) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
