# Minimal steps down to 1

**Candidate: proofs plausibly discharge automatically.** Everything is a bounded for-loop dynamic program over a fixed-size array where each index and increment is bounded by subtype ranges or an immediately preceding guard, so no annotation is required, though several loop-carried values (running minimum, trace position) need careful guards.

Position 181 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A fixed array Tab (1 .. 2000) of a ranged step-count subtype is filled by a for loop in a procedure parameterised by the subtractor (1 or 2), taking the minimum over divide-by-3, divide-by-2 and subtract, each guarded before indexing. A second for loop per number from 1 to 10 reconstructs one path by re-checking which move matches the table, printing with Put and 'Image, and a final pair of for loops finds the maximum and prints every number reaching it. The 20,000 stretch goal is left out. About 130 lines.

## Proof obligations to watch

- **overflow**: The 1 + Min_Steps increment on a loop-carried minimum is guarded by a test that Min_Steps is below the subtype's upper bound, with Reject as the visible outcome otherwise.
- **index**: Lookups at I/3, I/2 and I-Sub use subtype-bounded loop indexes with a guard I - Sub >= 1 placed just before use, and Sub is a subtype fixed to 1 or 2.
- **index**: The path-reconstruction loop carries Trace across iterations, so each step is guarded (Trace > Sub before subtracting, divisibility before dividing) and an inconsistent table Rejects rather than being assumed away.
- **overflow**: Count and maximum accumulators are bounded by their declared subtype ranges and the fixed table size of 2000, so no unchecked growth occurs.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the step counts, one reduction path per number, and the maximum-step numbers for both subtractors.

Assessed on 2026-10-15 against page revision 414343 of the [task](https://rosettacode.org/wiki/Minimal_steps_down_to_1) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
