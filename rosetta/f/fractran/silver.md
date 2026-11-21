# Fractran

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic and array scanning that guards can make safe, but parsing with loop-carried cursors and the overflow cap on the growing value need careful guard placement and no annotations. Extra-credit prime output grows past 64 bits, so only the base task is reliably in range.

Position 1129 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

The fraction list is an embedded String such as "17/91 78/85 ..." that a procedure parses with a while loop into fixed-capacity arrays of numerators and Positive denominators, rejecting malformed text or zero denominators with a message. A procedure then runs a for loop over a bounded step count, scanning the arrays with a while loop for the first fraction where N mod Den = 0, guarding N against a maximum value before multiplying, and printing each step with 'Image. It halts when no fraction applies, the step limit is reached, or the value limit is reached, each with its own message. About 120 lines.

## Proof obligations to watch

- **overflow**: The product N * Num is guarded by testing N against a fixed value bound divided by Num just before the multiply, with overflow producing a visible 'value limit reached' halt, since the value is a loop-carried variable known only by its subtype range.
- **index**: The parser's character cursor and fraction count are loop-carried, so every text read is preceded by a bound test against the string's length and the fraction count is tested against the array capacity before storing.
- **overflow**: Accumulating multi-digit numbers while parsing needs a digit-count or value-cap guard before each multiply-by-ten and add.
- **range**: Zero denominators must be rejected during parsing so the Positive denominator subtype and the mod operation are safe.
- **other**: The 20-prime extra credit needs values beyond 64 bits and far more steps than a bounded run, so it is left optional or needs fixed-capacity big numbers.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing, text parsing, 'Image of scalars, for loops, while loops, procedures, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): Each step's index and value is written to standard output.

Assessed on 2026-10-15 against page revision 414949 of the [task](https://rosettacode.org/wiki/Fractran) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
