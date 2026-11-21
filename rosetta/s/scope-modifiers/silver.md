# Scope modifiers

**Candidate: proofs likely to discharge automatically.** The task asks only for a demonstration of Ada's visibility mechanisms (package visible and private parts, bodies, nested declarations), and these are pure declarations with constant-valued straight-line code, so every check discharges from static values.

Position 1457 in the [progression](../../progression.md#stage-27), in stage 27.

## Approach

A user package declares a private type and public operations in its visible part, completes the type as a record in its private part, and keeps a helper function visible only inside its package body. Main declares a nested procedure whose local variable shadows an outer one, calls the package operations, and prints each scope rule with Put_Line, choosing messages with if statements that compare small integer values against literals. All arithmetic uses literal constants, so no check depends on a loop or on input. About 60 lines.

## Language surface recorded by this assessment

Integers, records, packages, procedures and functions.

## External effects

- **console output** (allowed): The program prints short explanations of each scope modifier and the results of using visible and hidden declarations.

Assessed on 2026-10-15 against page revision 413220 of the [task](https://rosettacode.org/wiki/Scope_modifiers) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
