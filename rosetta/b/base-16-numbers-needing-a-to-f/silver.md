# Base 16 numbers needing a to f

**Candidate: proofs likely to discharge automatically.** All arithmetic is on small ranged integers with a fixed three-iteration for loop instead of a while loop, so no termination or invariant facts are needed and only the Count increment needs a guard.

Position 112 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Main loops N over 1 .. 500 with a ranged-subtype copy C, and an inner for loop of three iterations (500 needs at most three hex digits) tests C mod 16 >= 10 then sets C := C / 16, setting a Boolean Found. Each qualifying N is printed with Put_Line using a trimmed 'Image string (one per line rather than 24 columns), Count is incremented behind a guard, and the final "Total count: " line is built by bounded concatenation with the Count image. About 30 lines.

## Proof obligations to watch

- **overflow**: The loop-carried Count is declared with a range and incremented only under a guard just before the increment, so the range check discharges.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each qualifying decimal number and the total count with Put_Line.

Assessed on 2026-10-15 against page revision 415525 of the [task](https://rosettacode.org/wiki/Base_16_numbers_needing_a_to_f) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
