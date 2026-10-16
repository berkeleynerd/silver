# Spelling of ordinal numbers

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic, constant tables and iterative buffer building with explicit capacity guards, so no annotations are needed, though the buffer-length and backward-scan loops need careful guarded shape. The optional alternate numeric forms (00123.0, 1.23e2) are skipped as optional.

Position 858 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Hold the test numbers in a constant array of a positive 64-bit range subtype; for each, a procedure fills a fixed-capacity character buffer with the spelling by walking six thousand-groups from most significant to least using a for loop over constant divisors, and spelling each 0..999 group with case statements on hundreds, tens and units into guarded appends. A second procedure finds the final word with a bounded backward while loop, replaces irregular endings (one, two, three, five, eight, nine, twelve) and y-to-ieth, or appends th, then prints the result with Put_Line. About 170 lines.

## Proof obligations to watch

- **index**: Word tables are indexed by values from n mod 1000 and the like, which discharge because the quotient and remainder subtypes are bounded by division by constants, and each group loop uses a for loop over fixed scale indexes.
- **length**: Appending words into a fixed buffer carries a loop-carried length, discharged by a Natural-ranged length subtype and an explicit guard before every append that sets a visible overflow flag (the buffer is sized above the longest 64-bit spelling, about 200 characters).
- **overflow**: Group extraction divides a 64-bit value by constant powers of 1000, which is safe with a positive-range input type and no accumulation of the value.
- **index**: Finding the last word scans backward in a while loop whose index is loop-carried, so it needs a guard (i greater than zero) in the loop condition before each string access.
- **other**: Padded fixed-length word tables need per-entry length handling because Silver has no unconstrained strings, so entries are stored with a separate length array to keep slices in range.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, for loops, while loops, procedures and case statements.

## External effects

- **console output** (allowed): Prints one ordinal word string per embedded test case with Put_Line.

Assessed on 2026-10-15 against page revision 415221 of the [task](https://rosettacode.org/wiki/Spelling_of_ordinal_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
