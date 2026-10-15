# Function prototype

**Candidate: proofs likely to discharge automatically.** Forward specifications, default parameters and named association are plain Ada declarations with no loops, recursion or contracts, and bounded parameter subtypes make the few arithmetic checks follow from types alone.

Position 322 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Main's declarative part holds forward specifications (prototypes) for a parameterless function, a two-argument function, a function with a defaulted optional argument and a procedure, each followed by its body and explained in comments (no varargs exist in Ada; named association is shown in calls). Parameters use a small ranged subtype such as -1000 .. 1000 so the integer arithmetic cannot overflow, and the statements call each subprogram, compare the result with an if, and print a line with Put_Line. About 45 lines.

## Language surface beyond today's Silver

Integers, ranged subtypes, functions and procedures.

## External effects

- **console output** (allowed): Put_Line reports that each declared and called subprogram behaved as expected.

Assessed on 2026-10-15 against page revision 388293 of the [task](https://rosettacode.org/wiki/Function_prototype) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
