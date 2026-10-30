# Hello world/Standard error

**Candidate: proofs likely to discharge automatically.** The program is a single call with a String literal, so every check is trivial once Silver admits a standard-error output operation.

Position 1556 in the [progression](../../../progression.md#stage-35), in stage 35, which adds standard error.

## Approach

A parameterless Main procedure with pragma SPARK_Mode (On) calls an admitted standard-error Put_Line operation with the literal "Goodbye, World!". There is no data, control flow or guard. About 6 lines.

## Language surface recorded by this assessment

Standard error.

## External effects

- **console output** (allowed): Writes one line to the standard error stream, a console output channel distinct from standard output.

Assessed on 2026-10-15 against page revision 413243 of the [task](https://rosettacode.org/wiki/Hello_world/Standard_error) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
