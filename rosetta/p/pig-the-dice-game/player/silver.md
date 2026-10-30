# Pig the dice game/Player

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged subtypes and loop guards placed just before each addition, with an embedded deterministic generator and procedure-only while loops, so nothing needs an annotation but loop-carried scores need careful shaping.

Position 618 in the [progression](../../../progression.md#stage-11), in stage 11.

## Approach

A Park-Miller linear congruential generator held in a ranged 64-bit subtype supplies die rolls (state mod 6 plus 1), and each of two fixed strategies (hold at a constant threshold, or hold at one threshold unless the opponent is near 100) is a Boolean function of turn score, own score and opponent score. A procedure plays one fully logged game with while loops guarded by the threshold and the 100-point target, then a fixed-count for loop plays an embedded number of unlogged games with a seed-advancing generator and prints the win counts and first-player advantage. Scores live in ranged subtypes bounded just above 100, and output uses Put_Line with Integer'Image concatenation into bounded strings. About 110 lines.

## Proof obligations to watch

- **overflow**: The Park-Miller step multiplies a 31-bit state by 48271 inside a 64-bit ranged type, which the provers discharge from the declared type ranges.
- **range**: Turn and game scores are loop-carried, so each while loop is guarded by the hold threshold (a constant of at most 100) and the 100-point target so the addition of a 2..6 roll stays within a ranged subtype without any invariant.
- **termination**: Game and turn loops are while loops confined to procedures, which receive no termination check, and the simulated game count is a fixed for loop.
- **index**: The die value is derived by mod 6 plus 1 from a ranged state and the win-count array is indexed by a two-valued subtype, so indices follow from types.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, procedures, functions, for loops, while loops, 'Image of scalars, string building, arrays and records.

## External effects

- **console output** (allowed): The program prints the strategies, a turn-by-turn game log and summary win counts.

Assessed on 2026-10-15 against page revision 412973 of the [task](https://rosettacode.org/wiki/Pig_the_dice_game/Player) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
