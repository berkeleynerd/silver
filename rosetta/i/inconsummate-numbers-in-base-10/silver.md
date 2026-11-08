# Inconsummate numbers in base 10

**Candidate: proofs likely to discharge automatically.** All checks follow from for-loop ranges, ranged digit subtypes and a guard before the array index, with no loop-carried unbounded values, so proofs should discharge automatically. The only extra needs are integer arithmetic, arrays, loops and number-to-text output.

Position 159 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Embed a Boolean array Consummate(0 .. 7000); a for loop over N in 1 .. 400000 computes the digit sum by six unrolled digit extractions (each (N / 10**k) mod 10 with a ranged subtype), so the sum is bounded without a loop-carried accumulator. When N mod Sum = 0 (Sum is at least 1 for N at least 1, guarded), the ratio N / Sum is marked if it is at most 7000. A second for loop scans 1 .. 7000 counting unmarked entries, printing the first 50 and the 1000th (6996) with Put_Line of a bounded image string. About 55 lines.

## Proof obligations to watch

- **division**: The digit sum is zero only for N = 0, so the loop starts at 1 and a guard Sum > 0 precedes mod and / to discharge the check.
- **overflow**: Counters and the digit sum are bounded by loop ranges and ranged digit subtypes, so no loop-carried unbounded value exists; the 400000 bound is documented as sufficient since sum is at most 54 and ratios are capped at 7000.
- **index**: The array index N / Sum is guarded by a comparison with 7000 immediately before the assignment.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, 'Image of scalars, string building and procedures.

## External effects

- **console output** (allowed): Prints the first fifty inconsummate numbers and the one thousandth.

Assessed on 2026-10-15 against page revision 414267 of the [task](https://rosettacode.org/wiki/Inconsummate_numbers_in_base_10) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
