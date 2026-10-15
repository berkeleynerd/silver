# Visitor pattern

**Candidate: proofs likely to discharge automatically.** Everything is a constant-size loop over an array's own range with exhaustive case statements and Put_Line calls, so no check can fail and nothing needs an annotation. The object-oriented dispatch is replaced by case statements, which the task allows for languages without OO support.

Position 1164 in the [progression](../../progression.md#stage-20), in stage 20.

## Approach

The class hierarchy is emulated with an enumeration of part kinds (Car, Car_Body, Engine, four Wheel positions) and a constant array holding the car's structure in visiting order. Two procedures, Print_Visit and Perform_Visit, each take a part kind and use a case statement over every enumeration value to print the line the Java example prints, and an Accept procedure loops over the array's own range calling the chosen visitor. Main runs the print visitor over the car and then the perform visitor. About 55 lines.

## Language surface beyond today's Silver

Enumerations, arrays, case statements, for loops and procedures.

## External effects

- **console output** (allowed): Each visitor prints one line per visited car part.

Assessed on 2026-10-15 against page revision 413426 of the [task](https://rosettacode.org/wiki/Visitor_pattern) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
