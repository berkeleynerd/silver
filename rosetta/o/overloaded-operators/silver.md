# Overloaded operators

**Candidate: proofs likely to discharge automatically.** The task only needs demonstrating overloaded operators on a few types, which is straight-line code with ranged-type arithmetic whose checks follow from declared ranges, so no annotation is required. Floating point, complex types and generics from the Ada example are optional and left out.

Position 583 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

The program shows built-in "+" on Integer and a ranged type, "&" on strings, and "=" on both Integer and String, then declares its own overloaded "+" and "=" functions on a small record vector type with narrow-ranged components returning a wider-ranged record. Each result is printed with Integer'Image concatenated into a line; no loops or input are needed, and the operand ranges are fixed by the types. About 45 lines.

## Proof obligations to watch

- **overflow**: The user-defined vector addition returns a wider-ranged record type than its operands so component sums cannot overflow, and integer demos use small constants or ranged operands.

## Language surface recorded by this assessment

Integers, ranged subtypes, records, functions, 'Image of scalars, string building and Boolean objects.

## External effects

- **console output** (allowed): The program prints each operation and its result with Put_Line.

Assessed on 2026-10-15 against page revision 413291 of the [task](https://rosettacode.org/wiki/Overloaded_operators) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
