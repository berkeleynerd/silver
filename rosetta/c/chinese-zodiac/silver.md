# Chinese zodiac

**Candidate: proofs likely to discharge automatically.** All arithmetic is small bounded integer work on a ranged year subtype with case statements over mod results, so every check follows from types and static bounds with no loop-carried values or recursion.

Position 784 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

A procedure takes a Year of a ranged subtype (1 .. 9999), computes the offset (Year - 1984) mod 60 with integer arithmetic bounded by the subtype, and derives the animal (offset mod 12), element ((offset mod 10) / 2) and yin/yang (offset mod 2), printing names via case statements and Put. The main procedure calls it for the embedded example years (1935, 1938, 1968, 1972, 1976, 1984, 1985, 2017, 2025), either by direct calls or a for loop over a small constant array, and the optional stem-branch names are omitted. About 90 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, case statements, procedures, Put without a newline, 'Image of scalars and for loops.

## External effects

- **console output** (allowed): Prints one line per embedded example year with its animal, element, yin/yang aspect and cycle position.

Assessed on 2026-10-15 against page revision 415362 of the [task](https://rosettacode.org/wiki/Chinese_zodiac) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
