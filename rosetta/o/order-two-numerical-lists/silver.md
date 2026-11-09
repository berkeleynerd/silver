# Order two numerical lists

**Candidate: proofs likely to discharge automatically.** Every index is bounded by the length subtype and the for-loop range, comparisons of Integer elements cannot overflow, and for loops terminate by themselves, so even inside a function no annotation is needed.

Position 343 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Lists are fixed-capacity Integer arrays (capacity 8) paired with a length of a subtype 0 .. 8, and a Boolean function Before takes both lists and lengths. It loops with a for loop over 1 .. the smaller length, returning True or False at the first differing element, and otherwise returns whether the first length is less than the second. A main procedure holds embedded example lists and prints true or false for each pair with an if statement. About 55 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, functions and procedures.

## External effects

- **console output** (allowed): Each embedded test pair prints true or false through Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413821 of the [task](https://rosettacode.org/wiki/Order_two_numerical_lists) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
