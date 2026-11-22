# Strange plus numbers

**Candidate: proofs likely to discharge automatically.** All values are bounded by the 101..499 loop range and digit sums of at most 18, every loop is a terminating for loop, and the only loop-carried value is a counter that a guard keeps in range, so checks follow from types and guards.

Position 334 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A for loop runs N over 101..499, splitting it into three digits with / and mod on a range-subtyped integer, and a non-recursive Is_Prime function trial-divides with a for loop from 2 to Sum-1 over digit sums bounded 0..18. Each N where both adjacent digit sums are prime is printed with Put of its Image plus a separator, with a line break every ten, and a final count is printed using a guarded bounded counter. About 45 lines.

## Proof obligations to watch

- **overflow**: The qualifying-number counter is loop-carried, so it is typed 0..400 and incremented only under an explicit if Count < 400 guard to discharge the range check.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the qualifying numbers and their count to standard output.

Assessed on 2026-10-15 against page revision 406227 of the [task](https://rosettacode.org/wiki/Strange_plus_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
