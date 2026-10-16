# Argument destructuring

**Candidate: proofs likely to discharge automatically.** The program is straight-line code with record aggregates and procedure calls that print constant strings, so there are no loops, arithmetic or index checks to prove and every check follows from the declarations.

Position 956 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

An Args record holds four fixed-length String components (two for the positional values, two for the named ones), built with a named-association aggregate. A procedure F takes four String parameters and prints a header plus each; an Apply procedure takes the record and calls F with its components spread out as arguments. Main builds one record with the example strings and calls Apply, so there are no loops, no input and no guards. About 35 lines.

## Language surface recorded by this assessment

Records, procedures, unconstrained arrays and ranged subtypes.

## External effects

- **console output** (allowed): F prints a header line and its four arguments with Put_Line.

Assessed on 2026-10-15 against page revision 415337 of the [task](https://rosettacode.org/wiki/Argument_destructuring) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
