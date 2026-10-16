# Top rank per group

**Candidate: proofs likely to discharge automatically.** Everything is bounded for loops over fixed arrays with index and salary types that bound all loop-carried values, so no annotation is needed. The only mild concern is the length check on concatenated output lines, which is bounded by the subtype ranges.

Position 1165 in the [progression](../../progression.md#stage-20), in stage 20.

## Approach

Employees are an array of 13 records (fixed-length Name and ID strings, a bounded Salary subtype, a Department enumeration) with the example data embedded as an aggregate, plus an array of Boolean Used flags and a constant N of 3. For each department (for loop over the enumeration), repeat N times a for loop over the employee index range that picks the largest unused salary in that department, tracked by a Found Boolean and a best index of the array's own index subtype, then mark it used and print it only when Found is true. No sorting or while loops are needed, so everything stays in for loops in the main procedure and all indexes come from the array's own range. About 65 lines.

## Proof obligations to watch

- **range**: Salary is a bounded subtype and the best-candidate index has a declared index subtype, so no loop-carried value needs an invariant.
- **length**: Concatenating 'Image of a bounded salary with fixed-length name and ID strings has a statically bounded length that fits the Put_Line argument limit.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, enumerations, arrays, records, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each department header and its top-N employee lines with Put_Line.

Assessed on 2026-10-15 against page revision 414549 of the [task](https://rosettacode.org/wiki/Top_rank_per_group) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
