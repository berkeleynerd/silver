# 100 doors

**Candidate: proofs likely to discharge automatically.** Every check follows from for-loop indexes over the array's own range, a divisor that the loop range keeps in 1 .. 100, and constant-bounded image strings, with no loop-carried values.

Position 108 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Declare a subtype Door_Index range 1 .. 100 and a Boolean array over it initialised to False (closed), then run nested for loops over the pass number and door index, toggling the door with "not" when J mod I = 0. A final for loop prints each line as Door_Index'Image(I) & " is open" or " is closed" with Silver_IO.Put_Line using plain if statements. About 25 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints one line per door stating whether it is open or closed.

Assessed on 2026-10-15 against page revision 414028 of the [task](https://rosettacode.org/wiki/100_doors) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
