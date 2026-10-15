# Pig the dice game

**Candidate: proofs likely to discharge automatically.** All arithmetic is bounded by ranged subtypes plus loop-condition guards, and the loops live in procedures so no termination check or annotation is needed. The only non-routine part is that the game ends with probability one rather than by a provable bound, which is irrelevant to procedures.

Position 1284 in the [progression](../../progression.md#stage-22), in stage 22.

## Approach

A deterministic modular LCG yields die rolls 1..6, and a procedure Play_Turn(Player score, state) rolls while the turn total is below a fixed hold threshold, zeroing the turn total on a 1, then adds the turn total to the score on hold. The main loop alternates two players with ranged Natural scores until one reaches 100, printing each roll, hold and score line via Put_Line with image conversion. Both players use a fixed hold-at-20 policy, so no input is needed and no interactive prompts exist. About 90 lines.

## Proof obligations to watch

- **overflow**: Turn total and score are ranged subtypes, and each addition occurs inside a while loop whose condition (turn below the hold threshold, score below 100) bounds the operands just before use.
- **range**: The die value is derived from a modular LCG state by mod 6 plus 1, which is statically within 1..6.

## Language surface beyond today's Silver

Integers, integer division, modular types, ranged subtypes, Boolean objects, records, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The simulation prints each roll, hold, running scores and the winner to standard output.

Assessed on 2026-10-15 against page revision 415436 of the [task](https://rosettacode.org/wiki/Pig_the_dice_game) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
