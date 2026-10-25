# Yin and yang

**Candidate: proofs likely to discharge automatically.** Text art meets the task's picture requirement, and every check is integer arithmetic on small ranged subtypes inside for loops, so proofs follow from types and loop bounds with no loop-carried state.

Position 440 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

A function Cell (R, X, Y) returns a Character ('#', '.', or ' ') using integer circle tests on squared distances (outer circle radius R, half-radius lobes, small eyes of radius R/5 or so) with R/2 computed on a ranged subtype. A procedure Draw (R) uses nested for loops over Y in -R .. R and X in -2*R .. 2*R (doubled width for character aspect), emitting each cell with Put and ending each row with Put_Line. Main calls Draw with two small constant sizes (for example 6 and 12). About 45 lines.

## Proof obligations to watch

- **overflow**: Squared-distance tests on coordinates are discharged because the radius is a small ranged subtype (for example 1 .. 20) and the loop indexes are bounded by it.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, for loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The two symbols are drawn as text art on standard output.

Assessed on 2026-10-15 against page revision 414997 of the [task](https://rosettacode.org/wiki/Yin_and_yang) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
