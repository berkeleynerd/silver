# 100 prisoners

**Candidate: proofs plausibly discharge automatically.** Every index and arithmetic check follows from subtype ranges, constant bounds and for loops, and the only loop-carried values (the generator state and win counters) need range types and a guard, with no variants or recursion required.

Position 409 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

The cupboard is a 1..100 array of a 1..100 subtype, filled with the identity and shuffled by Fisher-Yates driven by a deterministic LCG procedure holding its state in an in out parameter of a bounded range. A fixed number (a few thousand) of games runs in a for loop in a procedure; a Boolean function per strategy has every prisoner follow the card chain (optimal) or draw 50 pseudo-random drawers (random) in bounded for loops, and the loop stops reporting failure at the first prisoner who fails. Wins are counted behind a guard and the success percentages are printed with Put_Line using 'Image and concatenation. About 110 lines.

## Proof obligations to watch

- **overflow**: The linear congruential generator multiplies a state bounded by a declared 31-bit range by a constant, so the product stays under 2**62 and the following mod returns it to the state range.
- **overflow**: The win counters are loop-carried, so each increment sits behind a guard against the declared game count to discharge without an invariant.
- **index**: Card values and random picks are typed as a 1..100 subtype, so every array index follows from the type, and the chain-following loop is a plain for loop of 50 steps.
- **range**: The percentage Wins*100/Games is bounded by the capped counter type and a constant nonzero game count, so division and range checks follow from the types.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the two computed success percentages with Put_Line.

Assessed on 2026-10-15 against page revision 414029 of the [task](https://rosettacode.org/wiki/100_prisoners) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
