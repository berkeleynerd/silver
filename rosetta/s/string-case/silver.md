# String case

**Candidate: proofs likely to discharge automatically.** Every check (string index within 1 .. 9, Character'Val argument within 0 .. 255) follows from the fixed loop bounds and the range guard immediately before the conversion, with no loop-carried state. No termination, nonlinear or floating-point issues arise.

Position 497 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Keep the constant "alphaBETA" and copy it into fixed-length String variables of the same length (9) for the upper, lower and swapped results. A for loop over 1 .. 9 inspects each character, and an if guard tests whether it lies in 'a' .. 'z' or 'A' .. 'Z' just before adding or subtracting 32 via Character'Pos and Character'Val, so the result is always a valid Character. Each result is printed with Put_Line. About 35 lines.

## Language surface recorded by this assessment

Characters, string indexing, for loops and integers.

## External effects

- **console output** (allowed): Prints the upper-case, lower-case and optional swapped-case forms with Put_Line.

Assessed on 2026-10-15 against page revision 415378 of the [task](https://rosettacode.org/wiki/String_case) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
