# Water collected between towers

**Candidate: proofs plausibly discharge automatically.** All checks come from the declared height subtype, for loops over array ranges and a guarded accumulator, with no recursion or while loops, so it should prove without annotations but depends on careful guard placement for the loop-carried sum. Nothing here conflicts with the Oracle, and the new needs are only arrays, loops, procedures and integer-to-text.

Position 179 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Heights are stored in a fixed-capacity array of a 0..9 subtype with an explicit length (16), and a procedure fills a left-max array in a forward for loop and a right-max array in a reverse for loop. A second for loop adds min(left,right) minus height to a capped accumulator after a guard, and the main body calls the procedure for each of the seven embedded series, printing the totals with Put_Line. About 70 lines.

## Proof obligations to watch

- **overflow**: The water-sum accumulator is loop-carried with no invariant, so each addition is preceded by an explicit guard against a documented cap that rejects instead of altering the result.
- **range**: Heights are a subtype 0..9 and the running prefix and suffix maxima keep that subtype, so the water per tower (min of maxima minus height) is provably non-negative.
- **index**: Loops run over the array's own range so all indexing is statically in bounds, and series shorter than the fixed capacity are handled with a validated length used as the loop bound.
- **length**: Output lines are built by concatenation of Image text with bounded lengths, so the result buffer must be sized for the worst case.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, string building and integer division.

## External effects

- **console output** (allowed): Prints the water total for each of the seven embedded series.

Assessed on 2026-10-15 against page revision 414993 of the [task](https://rosettacode.org/wiki/Water_collected_between_towers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
