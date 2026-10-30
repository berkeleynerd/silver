# Merge and aggregate datasets

**Candidate: proofs likely to discharge automatically.** All data is embedded with small static bounds and loops are for loops over array ranges, so the only non-routine checks are the bounded score sum and the guarded division, both dischargeable from types and guards.

Position 1472 in the [progression](../../progression.md#stage-28), in stage 28.

## Approach

Embed the 5 patients and 8 visits as constant arrays of records (fixed-length ID, name and date strings, with a blank date and a Has_Score flag for missing values, and scores in integer tenths). For each patient, a for loop over the visits matches IDs, tracks the maximum date through string comparison, and accumulates the sum and count of scores. The program then builds each row, printing blanks when there is no date or no score, and computes the average as sum divided by count in hundredths, guarded by count greater than zero. About 90 lines.

## Proof obligations to watch

- **overflow**: Score sums are accumulated in a loop, but each score is a subtype 0..1000 tenths and at most 8 visits exist, so a ranged sum subtype or a guard before each addition discharges it.
- **division**: The average divides by the score count only inside an if branch testing that the count is greater than zero.
- **length**: Row strings are concatenated from fixed-width 'Image values of ranged subtypes, so the bounded concatenation length is statically known.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, string ordering, 'Image of scalars, string building, for loops and conditional expressions.

## External effects

- **console output** (allowed): The merged table is printed line by line with Put_Line.

Assessed on 2026-10-15 against page revision 413390 of the [task](https://rosettacode.org/wiki/Merge_and_aggregate_datasets) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
