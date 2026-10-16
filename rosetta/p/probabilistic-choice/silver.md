# Probabilistic choice

**Candidate: proofs plausibly discharge automatically.** Replacing floating point with exact integer fractions over 27720 and a deterministic bounded LCG makes every check follow from subtypes and for-loop bounds, with only the loop-carried counters needing careful guards.

Position 1184 in the [progression](../../progression.md#stage-20), in stage 20.

## Approach

Probabilities are exact integer numerators over 27720 (5544, 4620, 3960, 3465, 3080, 2772, 2520, 1759) held in a constant array indexed by an eight-value enumeration, so they sum exactly to one with no floating point. A deterministic 31-bit linear congruential generator in a ranged 64-bit type feeds a for loop of one million trials, each drawing state mod 27720 and scanning the cumulative thresholds with a for loop to pick the item and increment a bounded counter. A final for loop prints each item's name, target and observed frequency as integer parts per million. About 70 lines.

## Proof obligations to watch

- **overflow**: The LCG state stays below 2**31 so a 64-bit multiply cannot overflow, and the modulo result is re-bound by its subtype after each step.
- **overflow**: Per-item counters are loop-carried and are kept in range by a guard that increments only while the count is below the trial total, which never alters a result because the counts sum to exactly one million.
- **range**: The draw is state mod 27720 so it lies in a declared subtype, and the cumulative-threshold scan uses a for loop over the item enumeration with the accumulated threshold typed to 0..27720.
- **range**: Parts-per-million output scaling multiplies counts bounded by 1_000_000 by a constant, which fits in 64 bits via type bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, enumerations, arrays, records, for loops, while loops, 'Image of scalars, string building, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints one line per item with the target and observed frequencies.

Assessed on 2026-10-15 against page revision 413859 of the [task](https://rosettacode.org/wiki/Probabilistic_choice) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
