# Implicit type conversion

**Candidate: proofs likely to discharge automatically.** Ada has few implicit conversions (literals and subtype widening), so a faithful demonstration uses only constants, subtype ranges and guarded explicit conversions that GNATprove discharges from types and guards, with no loops or recursion.

Position 73 in the [progression](../../progression.md#stage-5), in stage 5.

## Approach

Declare a chain of integer subtypes of increasing size (for example 8-bit, 16-bit, Integer, 64-bit) plus a distinct derived type, then assign values up the subtype chain implicitly and across the derived type with explicit conversions, printing each with a label via 'Image. The user-defined conversion is a small function between two types, and any narrowing step is guarded by an if comparison before the conversion. About 45 lines.

## Proof obligations to watch

- **range**: Narrowing explicit conversions between the declared integer types are applied only to constants or after an explicit if guard on the value's range, so each range check follows from the guard.

## Language surface beyond today's Silver

Integers, ranged subtypes, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each converted value with a label to standard output.

Assessed on 2026-10-15 against page revision 412842 of the [task](https://rosettacode.org/wiki/Implicit_type_conversion) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
