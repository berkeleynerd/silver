# Shuffle groups

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared ranges, fixed for-loop bounds and a few guards on loop-carried counters, with no recursion or heap use, so it is plausible rather than routine; the core task needs only values under about 1.5 million while the 10-digit exactly-4 stretch is both too slow and outside the chosen range.

Position 844 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

The program loops n over a declared range (1000 up to about 1,500,000 for the stretch), skips multiples of 10, and builds a ten-element digit-count array for n by a fixed-length for loop of repeated division by 10 guarded by n > 0. For each multiplier 2..9 it builds the digit-count array of n*k (if within the range) and compares it with the base's, collecting witnesses into a small array, then records the first 20 groups, the first group with more than 4 witnesses, and a tally array indexed by witness count 1..8, stopping the scan when the needed milestone is reached. Results are printed with Put_Line using 'Image and bounded concatenation. About 130 lines.

## Proof obligations to watch

- **overflow**: Candidates are bounded by a declared range of at most 1,500,000 and products by 9 times that, so a subtype of Integer discharges them, and the 10-digit exactly-4 stretch is left out because it needs 64-bit values and a 40-minute search.
- **overflow**: Digit-count increments and the per-witness-count tallies are loop-carried values with no invariant, so each increment is guarded (for example only while the count is below a declared cap) or uses a wide enough range type.
- **index**: Digit extraction uses n mod 10 converted to a 0..9 subtype indexing a 0..9 count array, and group storage for the first 20 entries and the tally by witness count (1..8) are guarded before indexing.
- **termination**: All loops are for loops over static ranges (a fixed 7 or 10 digit positions guarded by n > 0, candidates 1000..150000 and multipliers 2..9), so no variants are needed.
- **length**: Output lines are concatenations of Image values and literals with a bounded maximum size, which must be sized so the bounded concatenation cannot exceed its limit.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, functions, 'Image of scalars, string building and case statements.

## External effects

- **console output** (allowed): Prints the first 20 groups, the first group with more than 4 witnesses (142857 at index 144) and the witness-count breakdown, plus the exactly-3 stretch (1402857) as optional lines.

Assessed on 2026-10-15 against page revision 408839 of the [task](https://rosettacode.org/wiki/Shuffle_groups) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
