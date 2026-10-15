# Unescape a string

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic and character handling in a procedure-based while loop, so each check can be discharged by explicit guards placed before each lookahead and by range-typed hex digits, with no annotation needed. The risk is the careful guard shape for index and arithmetic bounds across many loop-carried values.

Position 1033 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

The program embeds the 14 test strings and calls one procedure per string that scans a String parameter in a while loop, writing decoded bytes into a fixed 128-byte output buffer and returning a length and an Ok flag. A case statement handles the eight two-character escapes, while \u escapes use a hex-digit helper with range-checked values, surrogate-pair combination, and a UTF-8 byte encoder using division and mod by constants. Every lookahead is guarded by an index bound and every invalid case (truncated, bad hex digit, lone or mismatched surrogate, unknown escape) sets Ok to False and prints a specific error message. About 170 lines.

## Proof obligations to watch

- **index**: The scan index advances by 1, 2, 6 or 12 positions in a while loop with no invariant, so every Input(I+k) read and every Output write is preceded by an explicit bound guard (I+5 <= Input'Last, Out_Len + 4 <= Output'Last) with the failing case rejected as an error.
- **overflow**: Hex accumulation and the surrogate-pair formula 16#10000# + ((H-16#D800#)*1024) + (L-16#DC00#) are nonlinear loop-carried arithmetic that discharges only if each hex digit is range-checked to 0..15 and the accumulator is a subtype 0..65535, which the program does by guarding each digit.
- **range**: Character'Val conversions of UTF-8 bytes computed with div and mod by constants need the code point constrained to 0..16#10FFFF# and each byte to 0..255, which holds after the surrogate and control-character guards.
- **termination**: The while loop sits in a procedure so no termination check applies, and the index strictly increases on every path.
- **length**: Output is a fixed-capacity buffer with a separate length, and capacity exhaustion is a specified error outcome rather than a silent truncation.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, unconstrained arrays, string indexing, string building, case statements, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Each test input and its unescaped result or an error message is printed to standard output.

Assessed on 2026-10-15 against page revision 385179 of the [task](https://rosettacode.org/wiki/Unescape_a_string) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
