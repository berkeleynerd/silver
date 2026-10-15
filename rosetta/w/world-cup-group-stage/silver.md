# World Cup group stage

**Candidate: proofs plausibly discharge automatically.** All loops are for loops over fixed ranges inside procedures, so termination is free and the checks reduce to guarded accumulator increments and bounded array indexes. The nonroutine parts are loop-carried sums and counts plus text formatting, which need careful shape but no annotations.

Position 821 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

A for loop over outcome numbers 0..728 decodes six base-3 digits into win/draw/loss per game and adds 3/1/0 points to four team totals held in a small array, with guarded increments. The four totals are sorted by a fixed bubble-sort procedure with for loops, then a 4x10 count array indexed by place and points is incremented. Finally a procedure prints a header and four rows, formatting each count to a fixed width using bounded string building. About 90 lines.

## Proof obligations to watch

- **overflow**: Per-team point sums and histogram counts are loop-carried, so each increment is preceded by a guard (for example the value is below a cap) that cannot trigger for real inputs but must be written visibly.
- **index**: Indexing the count table by a team's total points needs the total bounded to 0..9 or the table sized to the type's range, since no invariant can state the true maximum of 9.
- **range**: Decoding the outcome number into base-3 digits with div and mod must stay within 0..2 per game, which follows from mod 3 on a bounded non-negative loop index.
- **other**: Formatting counts into fixed-width columns needs bounded string building with padding computed from digit counts.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, records, string building, 'Image of scalars, for loops, procedures, case statements, characters and Put without a newline.

## External effects

- **console output** (allowed): The histogram table of counts per place and points is printed line by line.

Assessed on 2026-10-15 against page revision 413967 of the [task](https://rosettacode.org/wiki/World_Cup_group_stage) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
