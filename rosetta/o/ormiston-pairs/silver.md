# Ormiston pairs

**Candidate: proofs plausibly discharge automatically.** All checks follow from fixed array bounds, for-loop indexes and guards before the sieve step and signature accumulation, with no annotation needed, but the loop-carried signature and sieve stride need careful guard placement.

Position 389 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Sieve of Eratosthenes into a constant-size Boolean array of 1_000_001 entries, then a for loop over 2..1_000_000 tracks the previous prime and compares digit-multiset signatures, computed by a bounded digit-extraction loop with guarded accumulation. The first 30 pairs are output with Put_Line of bounded concatenated image strings, and a bounded count is printed at the end; the ten-million stretch is left out as optional. About 70 lines.

## Proof obligations to watch

- **index**: Sieve indexes stay within 0..1_000_000 because every index is a for-loop variable over the array range or is guarded by j <= Limit - i before the update.
- **overflow**: The digit-signature accumulator is a loop-carried value, so it is held in a 64-bit type and each add is preceded by a guard on its current value (or the digit loop is a fixed 7-iteration for loop over bounded per-digit counts).
- **termination**: The while loops live only in procedures, which get no termination check, and the prime scan is a for loop over a static range.
- **range**: The count of pairs and the output line buffer are given bounds large enough (count well under 1000) so subtype range and length checks follow from declarations.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 30 pairs and the count up to one million as text lines.

Assessed on 2026-10-15 against page revision 414373 of the [task](https://rosettacode.org/wiki/Ormiston_pairs) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
