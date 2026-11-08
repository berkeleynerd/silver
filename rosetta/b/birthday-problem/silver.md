# Birthday problem

**Candidate: proofs likely to discharge automatically.** All data are fixed-size arrays and ranged integers with loops bounded by constants, so every index and overflow check follows from types and no loop needs a variant or invariant; the only care needed is declaring ranges on several loop-carried counters.

Position 348 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

For each multiplicity m in 2..5, run a fixed number of trials; each trial resets a 365-entry day-count array, then adds people one at a time with a for loop up to 4*365+1 using a deterministic LCG for the birthday, exiting once any day count reaches m, and tallies the group size in a histogram array. A final for loop accumulates the histogram until the cumulative count passes half the trials and prints that size via 'Image concatenated into Put_Line; the simulation lives in procedures with the seed passed in out and a fixed documented trial count. About 70 lines.

## Proof obligations to watch

- **overflow**: The linear congruential generator multiplies a state bounded by a declared 31-bit range by a literal constant, so the product stays under 2**63 and the check discharges from the type range.
- **index**: Day indexes come from a mod 365 on a non-negative ranged value and group-size histogram indexes come from a for loop bounded by the pigeonhole limit 4*365+1, so both discharge from types.
- **overflow**: Per-day counters and histogram tallies are loop-carried, so they are declared with ranges wide enough for trials times people and incremented under a guard just before use.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, functions, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the estimated group size for each of multiplicities 2 to 5 with Put_Line.

Assessed on 2026-10-15 against page revision 414080 of the [task](https://rosettacode.org/wiki/Birthday_problem) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
