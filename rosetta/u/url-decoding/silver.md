# URL decoding

**Candidate: proofs plausibly discharge automatically.** All checks come from ranged subtypes and guards placed just before each index or conversion, and the loop is in a procedure so no variant is needed; the loop-carried indices need careful guarding, hence plausible rather than likely.

Position 1020 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

A procedure Decode takes an input String and fills a fixed-capacity output String buffer plus a ranged length, scanning with a while loop that maps '+' to space, '%XX' to the byte from two hex digits, and anything else to itself. Guards reject truncated or non-hex escapes and buffer overflow with a visible reject message, and the three test strings are embedded constants whose decoded results (including the UTF-8 bytes for 'á' and the %25%32%35 to %25 case with a single pass) are printed with Put_Line. About 95 lines.

## Proof obligations to watch

- **index**: The write index into the bounded output buffer is loop-carried, so a guard before each store rejects input that would exceed the buffer capacity, and a guard that Position+2 does not pass the last index precedes reading the two hex digits.
- **overflow**: Position and Filled are declared as ranged subtypes with spare headroom and guarded before each increment, so Position+3 and Filled+1 cannot overflow.
- **range**: Hex digits are converted by explicit comparisons to values 0..15 so Hi*16+Lo lies in 0..255 and Character'Val cannot fail, with a non-hex digit giving a visible reject outcome.
- **termination**: The while loop sits in a procedure, which gets no termination check, and Position strictly advances on every branch.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, unconstrained arrays, string indexing, string building, for loops, while loops, procedures, case statements and Boolean objects.

## External effects

- **console output** (allowed): Each decoded test string is printed with Put_Line.

Assessed on 2026-10-15 against page revision 411785 of the [task](https://rosettacode.org/wiki/URL_decoding) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
