# Moser's circle problem

**Candidate: proofs likely to discharge automatically.** Every operand is bounded by the Points subtype, so all overflow and division checks discharge from types, and the only loop is a for loop over a static range with no loop-carried values.

Position 314 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Declare subtype Points is Integer range 1 .. 20 and two side-effect-free functions: one evaluating the quartic formula divided by 24, the other evaluating C(n,4)+C(n,2)+1 with explicit products and divisions. A for loop over Points builds a line per n by concatenating Integer'Image of both results with a match flag chosen by an if, printing with Silver_IO.Put_Line. All data is embedded and no input is read. About 40 lines.

## Proof obligations to watch

- **overflow**: The degree-four polynomial and the product n*(n-1)*(n-2)*(n-3) stay far below Integer'Last because the argument is a subtype 1 .. 20, so the provers bound every intermediate by range reasoning.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, for loops, 'Image of scalars, string building and functions.

## External effects

- **console output** (allowed): Prints the 20 values from each of the two methods as lines of text.

Assessed on 2026-10-15 against page revision 415212 of the [task](https://rosettacode.org/wiki/Moser's_circle_problem) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
