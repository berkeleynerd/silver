# Passphrase generator

**Candidate: proofs likely to discharge automatically.** Every check follows from static array bounds, a ranged length subtype, modular wraparound and mod by static constants, and printing word by word avoids a loop-carried buffer position, so all checks should discharge without annotations.

Position 1269 in the [progression](../../progression.md#stage-21), in stage 21.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

An embedded constant array holds capitalized words as fixed-width String (1 .. 9) entries, alongside a length table with subtype 1 .. 9. A mod 2**32 linear congruential generator with a fixed seed picks each word index and a two-digit suffix in 10 .. 99. A for loop over 1 .. N prints each word slice, the two digit characters and a "-" separator before every word except the last, using Put, then finishes the line. N is a single-digit first argument that defaults to "5"; any other value is rejected through Reject. About 60 lines.

## Proof obligations to watch

- **index**: Word slices Words (I)(1 .. Lengths (I)) and the chosen index (State mod Word_Count) + 1 are safe because the length table has subtype 1 .. 9 and the mod result is bounded by the array range.
- **range**: Converting the modular PRNG state to the word index and the 10 .. 99 suffix stays in range because mod by a static positive constant bounds the result, and digit characters come from Character'Val of '0' plus a value in 0 .. 9.

## Language surface recorded by this assessment

Integers, integer division, modular types, ranged subtypes, characters, arrays, string indexing, text parsing, for loops and Put without a newline.

## External effects

- **console output** (allowed): The passphrase is written to standard output.
- **arguments** (allowed): The word count n is read from the first command-line argument, with a default of 5 and rejection of invalid values.

Assessed on 2026-10-15 against page revision 415555 of the [task](https://rosettacode.org/wiki/Passphrase_generator) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
