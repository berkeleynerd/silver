# Motor

**Candidate: proofs likely to discharge automatically.** The program only declares fixed-size float records, assigns literals and prints components, so every check is routine and the only new needs are floating-point types and float formatting.

Position 1030 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

The task text is only a list of related tasks, so the program defines a Quat record of four floats, a Motor record holding a Rotor and a Screw Quat, and embeds the example motor with rotor (1,0,0,0) and screw (0,1,0,0). It reads the components through accessor functions, updates the rotor x to 2.0 on a variable copy, and prints the components with float image. There are no loops, divisions or arithmetic beyond assignment, so no guards are needed. About 35 lines.

## Language surface recorded by this assessment

Floating point, records, floating-point images, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the rotor and screw components of the example motor.

Assessed on 2026-10-15 against page revision 402081 of the [task](https://rosettacode.org/wiki/Motor) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
