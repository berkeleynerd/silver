# Code Golf

**Candidate: proofs likely to discharge automatically.** The task needs only fixed output of nine characters through a for loop over a constant array, with every check following from the component subtype and the array's own index range, so the proofs discharge routinely once an unterminated Put exists. Shortest-program golfing and the executable-size extra credit are not program requirements, so nothing conflicts with the Oracle.

Position 426 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

The first program is a Main procedure that calls an unterminated Put of the literal "Code Golf"; the second is a Main procedure holding a constant array of nine character codes, declared as a subtype of 0 .. 255, and a for loop over the array's own range that emits Character'Val of each element with a character-level Put. No input, arguments or program name are used, and the Character'Val argument is bounded by the component subtype, so no guard is needed. About 12 lines.

## Language surface recorded by this assessment

Put without a newline, arrays, for loops, characters, ranged subtypes and integers.

## External effects

- **console output** (allowed): Writes the nine characters Code Golf to standard output with no line terminator.

Assessed on 2026-10-15 against page revision 411793 of the [task](https://rosettacode.org/wiki/Code_Golf) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
