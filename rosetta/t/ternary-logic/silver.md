# Ternary logic

**Candidate: proofs likely to discharge automatically.** Every operator is a total case statement over a three-value enumeration, and all loops are for loops over the enumeration range, so no run-time check depends on a loop-carried value and no annotation is needed. The only new surface is enumerations, case statements, functions and bounded string building, all routine for the provers.

Position 1176 in the [progression](../../progression.md#stage-20), in stage 20.

## Approach

Define a three-valued enumeration Trit (True, Maybe, False, with non-clashing identifiers) and total pure functions Not_T, And_T, Or_T, Implies_T and Equiv_T, each a case statement on one or both arguments that returns the table's value explicitly, with no exceptions needed. A function Image returns a one-character String, and procedures run for loops over the Trit type (nested for the binary operators) and print each row built by bounded concatenation of fixed-length pieces. All data is embedded, with no input. About 90 lines.

## Language surface beyond today's Silver

Enumerations, case statements, functions, procedures, for loops, characters, string building and Boolean objects.

## External effects

- **console output** (allowed): Prints the truth tables for not, and, or, implies and equivalence line by line with Put_Line.

Assessed on 2026-10-15 against page revision 411890 of the [task](https://rosettacode.org/wiki/Ternary_logic) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
