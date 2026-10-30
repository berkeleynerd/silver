# Enumerations

**Candidate: proofs likely to discharge automatically.** The task only requires declaring enumerations and constants and printing them, which needs types, static values and a for loop over an enumeration's own range, so every check discharges from declarations alone.

Position 1146 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

The program declares an enumeration type Fruit (apple, banana, cherry) for the implicit-value case, and a second set of constants with explicit values as an integer subtype and constants, for example Apple_Code : constant Integer := 1, Banana_Code := 2, Cherry_Code := 4. A for loop over Fruit prints each literal with Fruit'Image and Fruit'Pos, and the explicit values are printed with Integer'Image in Put_Line. Every operation is a static bound or a loop over a type's own range, so no guards are needed. About 30 lines.

## Language surface recorded by this assessment

Enumerations, ranged subtypes, integers, for loops, 'Image of scalars and procedures.

## External effects

- **console output** (allowed): The program prints each enumeration literal's name and its position or explicit value.

Assessed on 2026-10-15 against page revision 414648 of the [task](https://rosettacode.org/wiki/Enumerations) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
