# Banker's algorithm

**Candidate: proofs likely to discharge automatically.** The task is bounded array arithmetic on embedded data with nested for loops and one while loop in a procedure, so every check follows from ranged subtypes and explicit guards, and nothing needs a variant or invariant.

Position 1164 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

The program embeds the example (4 resource types, 3 processes) as constrained arrays: a Total vector plus Allocation and Maximum matrices indexed by enumeration or small ranged subtypes. A main procedure sums each allocation column, validates that the totals fit within Total and that Allocation does not exceed Maximum (rejecting with a visible message otherwise), derives Available and Need, then loops in a procedure: pick an unfinished process whose Need fits within Available, add its allocation back, and print it, or report an unsafe state if none fits. Counts are subtypes bounded to a small range so every addition is guarded by a bound comparison before use. About 90 lines.

## Proof obligations to watch

- **overflow**: Summed and updated resource counts are loop-carried, so they use a small ranged subtype (0..1000) with each addition guarded by a comparison against the bound just before it, and an over-limit total rejects the input.
- **termination**: The outer scheduling loop lives in a procedure, which gets no termination check, and it also ends because each pass either marks a process finished or exits.
- **index**: All indexing is by for-loop variables over the fixed constrained array ranges, so index checks follow from the loop ranges.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, enumerations, arrays, multidimensional arrays, records, for loops, while loops, procedures, 'Image of scalars, Put without a newline, string building and conditional expressions.

## External effects

- **console output** (allowed): Prints the available resources, each process as it runs, and the safe or unsafe verdict.

Assessed on 2026-10-15 against page revision 386552 of the [task](https://rosettacode.org/wiki/Banker's_algorithm) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
