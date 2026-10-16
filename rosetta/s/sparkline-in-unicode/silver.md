# Sparkline in unicode

**Candidate: proofs plausibly discharge automatically.** All checks follow from bounded integer subtypes, fixed array capacity and explicit guards before each operation, with no annotation-only facts, but the loop-carried parser accumulator and count need carefully placed guards.

Position 1141 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Embed the task's example inputs as String constants and process each in a procedure that scans characters with a while loop, treating space and comma as separators, parsing decimals into tenths-scaled integers in a fixed-capacity array of at most 64 values with digit-count and capacity guards that reject invalid input with a message. It then finds min and max, maps each value to a bin 0..7 with integer arithmetic, and appends the three UTF-8 bytes (E2 96 81+bin) per value to a bounded String buffer that is printed with Put_Line. About 130 lines.

## Proof obligations to watch

- **overflow**: The parser accumulates each number digit by digit in a loop, so it guards the digit count (rejecting numbers beyond a fixed limit such as 6 digits) so the accumulator stays within a bounded integer subtype.
- **index**: The value count and output buffer position are loop-carried, so each store is preceded by an explicit capacity guard that rejects overlong input, and the output buffer is sized at 3 bytes per value.
- **range**: The bin computation (value minus minimum) times 7 divided by range is nonlinear, but values are bounded scaled integers so the product fits in Integer and the result is guarded to 0..7.
- **division**: The range divisor is replaced by 1 when all values are equal, which is a visible and specified outcome (all lowest bars).
- **termination**: The tokenizing while loop lives in a procedure, which gets no termination check, and always advances the position by at least one.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, text parsing, for loops, while loops and procedures.

## External effects

- **console output** (allowed): Each sparkline is written to standard output as one line of UTF-8 block characters.

Assessed on 2026-10-15 against page revision 415078 of the [task](https://rosettacode.org/wiki/Sparkline_in_unicode) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
