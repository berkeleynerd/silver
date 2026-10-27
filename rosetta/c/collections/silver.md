# Collections

**Candidate: proofs likely to discharge automatically.** Every check follows from the array's declared index range, a count typed with the capacity as its upper bound, a capacity guard just before each append, and a for loop over a bounded range, so no annotation is needed.

Position 74 in the [progression](../../progression.md#stage-4), in stage 4.

## Approach

The program declares a fixed-capacity collection as a constrained Integer array of 8 elements plus a Natural count bounded by that capacity, and a procedure Add that appends a value only when the count is below capacity and otherwise prints a visible "full" message. It adds three values (1, 2, 3) from the main body, then a for loop over 1 .. Count prints each element using 'Image with Put_Line. About 30 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The program prints the collection's elements so the added values are observable.

Assessed on 2026-10-15 against page revision 414116 of the [task](https://rosettacode.org/wiki/Collections) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
