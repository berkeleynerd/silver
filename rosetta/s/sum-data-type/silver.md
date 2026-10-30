# Sum data type

**Candidate: proofs likely to discharge automatically.** The task is a variant record demonstration whose only checks are discriminant and index checks that follow from the declared types and a guard on Found, and the function uses a for loop so it needs no variant. No annotations are needed, and the Ada solution's Pre/Post contracts are not required for a faithful sum type.

Position 1576 in the [progression](../../progression.md#stage-45), in stage 45, which adds variant records.

## Approach

Declare a subtype Index range 1 .. 8, a constrained array of Integer over it, and a variant record Ret_Val (Found : Boolean) whose True variant holds Position : Index. A function Find_First scans with a for loop over the array's own range and returns the record, then Main embeds sample data, searches for one present and one absent value, and prints each result, reading Position only inside an if on Found. About 35 lines.

## Proof obligations to watch

- **discriminant**: Reading Position is checked against the Found discriminant, which discharges because the read sits inside an if branch testing Found just before use.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, records, variant records, 'Image of scalars, for loops, functions and string building.

## External effects

- **console output** (allowed): Prints whether the value was found and at which position.

Assessed on 2026-10-15 against page revision 413074 of the [task](https://rosettacode.org/wiki/Sum_data_type) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
