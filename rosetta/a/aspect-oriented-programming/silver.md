# Aspect oriented programming

**Candidate: proofs likely to discharge automatically.** The task asks only to describe or show how far a language can simulate AOP, so a wrapper-based demo with embedded data and a range-bounded addition needs only type-range and static-value checks and no annotations.

Position 294 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

The program defines a plain Add2 function on a ranged subtype, and a wrapper procedure that prints a trace line before calling Add2 and a trace line after, standing in for before and after advice around a join point. Main prints a few lines explaining that Silver simulates aspects only by explicit wrapping (no invisible instrumentation), then calls the plain and wrapped versions on the embedded value 5 and prints both results. No loops or recursion are used and all data is embedded. About 30 lines.

## Proof obligations to watch

- **overflow**: Add2 takes a subtype whose range stops 2 below Integer'Last, so X + 2 cannot overflow, and the demo passes the literal 5.

## Language surface recorded by this assessment

Integers, ranged subtypes, functions, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): The program prints a short description of what Silver can simulate and the traced and untraced call results with Put_Line.

Assessed on 2026-10-15 against page revision 415158 of the [task](https://rosettacode.org/wiki/Aspect_oriented_programming) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
