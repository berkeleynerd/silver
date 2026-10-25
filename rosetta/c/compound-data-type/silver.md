# Compound data type

**Candidate: proofs likely to discharge automatically.** A plain two-field record over a bounded integer subtype involves only static ranges and literal values, so every range and initialization check follows from types and discharges automatically.

Position 575 in the [progression](../../progression.md#stage-11), in stage 11, which adds records.

## Approach

Declare a bounded integer subtype Coordinate, a record type Point with X and Y components of that subtype, and a constant and a variable Point built from an aggregate. Update a component by assigning an in-range literal or a guarded computed value, then print both components with 'Image through Silver_IO.Put_Line. No loops or recursion are used. About 22 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, records, Put without a newline, 'Image of scalars and procedures.

## External effects

- **console output** (allowed): Prints the point's components to show the record works.

Assessed on 2026-10-15 against page revision 412720 of the [task](https://rosettacode.org/wiki/Compound_data_type) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
