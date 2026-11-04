# Price fraction

**Candidate: proofs likely to discharge automatically.** Every index and digit computation is bounded by the declared 0..100 subtype and the for-loop range, so range and index checks follow from types with no loop-carried state. The for loop needs no variant and the division is by a literal.

Position 443 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Prices are held as integer hundredths in a subtype 0..100, with a constant 20-entry array of output hundredths indexed by a bucket 0..19 computed as 0 for zero and (V - 1) / 5 otherwise. A for loop over 0..100 looks up each result and a small procedure formats two hundredths values as "d.dd" through fixed-size String variables built from digit characters, then calls Put_Line. Floating point and fixed-point are avoided entirely so rounding cannot arise. About 50 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, characters, string building and procedures.

## External effects

- **console output** (allowed): Prints the 101 input-to-price lines with Put_Line.

Assessed on 2026-10-15 against page revision 414414 of the [task](https://rosettacode.org/wiki/Price_fraction) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
