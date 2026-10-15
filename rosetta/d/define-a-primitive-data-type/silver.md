# Define a primitive data type

**Candidate: proofs likely to discharge automatically.** The task is a declared range type with checked conversions, which follows directly from types and guards placed just before each conversion or addition, so proofs should discharge routinely.

Position 48 in the [progression](../../progression.md#stage-3), in stage 3.

## Approach

Declare type My_Type is range 1 .. 10, then use constants and variables of that type and a for loop over My_Type printing each value with 'Image. A candidate Integer value is tested with an explicit guard 'if C >= 1 and then C <= 10' before conversion to My_Type, and a visible rejection message is printed otherwise. Arithmetic is done by widening to Integer, guarding the result to the range, and converting back. About 30 lines.

## Language surface beyond today's Silver

Integers, ranged subtypes, for loops, Put without a newline and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the demonstrated values and the outcome of validating an out-of-range candidate.

Assessed on 2026-10-15 against page revision 412738 of the [task](https://rosettacode.org/wiki/Define_a_primitive_data_type) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
