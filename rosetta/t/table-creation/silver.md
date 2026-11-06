# Table creation

**Candidate: proofs likely to discharge automatically.** The task has no real database requirement beyond demonstrating a table of typed columns, so a record with ranged fields, printed as schema text plus a sample row, is faithful and every check follows from declared ranges.

Position 585 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

The program declares ranged subtypes for ID, Age and Salary in cents and a record type Person with fixed-length String components, then builds one embedded Person constant as the table row. A procedure prints the CREATE TABLE text as literal lines and then each column of the row, converting numbers with 'Image into a bounded buffer sized for the maximum range. No loops or input are needed, so all checks follow from the declared ranges. About 45 lines.

## Language surface recorded by this assessment

Records, ranged subtypes, integers, 'Image of scalars, string building and procedures.

## External effects

- **console output** (allowed): The program prints the CREATE TABLE statement and the sample row to standard output.

Assessed on 2026-10-15 against page revision 410676 of the [task](https://rosettacode.org/wiki/Table_creation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
