# Balanced ternary

**Candidate: proofs plausibly discharge automatically.** All loops are bounded for loops over a fixed capacity and every narrowing or index is protected by a local guard, so no annotation should be needed, though carry chains and guarded integer accumulation require careful shape. The arbitrary-size requirement is met with a documented fixed capacity and explicit overflow reporting.

Position 1398 in the [progression](../../progression.md#stage-26), in stage 26.

## Approach

Represent a number as a record of a fixed-capacity array of 40 trits (a -1..1 subtype, least significant first) plus a length and an overflow flag. Procedures implement parse from text, from Integer, to Integer, to text, negate, add (carry loop), and multiply (shift-and-add using for loops with guarded indexes), and the main procedure embeds the test case and prints the results with Put_Line. All conversions use for loops over the fixed capacity, and overflow produces a visible rejection message rather than wrapped values. About 230 lines.

## Proof obligations to watch

- **overflow**: Trit sums and carries are computed in a small Integer range and checked against -1..1 after reduction, so they follow from the types and a guard before each narrowing.
- **index**: Product positions I+J-1 are guarded against the fixed capacity and any excess nonzero trit sets a visible overflow flag instead of indexing out of range.
- **overflow**: Conversion to a native integer accumulates value and place weight through a loop with no invariant, so each step is guarded by an explicit magnitude limit that reports overflow rather than wrapping.
- **range**: Integer-to-trit conversion repeatedly divides a loop-carried value by 3 using mod and rem, which is nonlinear but stays within the Integer type and loops over a fixed trit count.
- **other**: Arbitrary size is replaced by a documented fixed capacity (for example 40 trits) with overflow reported explicitly, which Oracle rule 7 permits.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, records, for loops, while loops, case statements, procedures, functions, Boolean objects, big numbers, string building, 'Image of scalars, text parsing, string indexing and Put without a newline.

## External effects

- **console output** (allowed): Prints a, b, c in decimal and the product in ternary and decimal.

Assessed on 2026-10-15 against page revision 413460 of the [task](https://rosettacode.org/wiki/Balanced_ternary) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
