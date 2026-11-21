# Stair-climbing puzzle

**Candidate: proofs plausibly discharge automatically.** The recursion in the task's pseudo-code can be replaced by an explicit pending-steps counter in a procedure, so no variant is needed and all checks follow from bounded subtypes and guards. The nonrecursive form is a faithful equivalent, and the only non-routine items are loop-carried counters that need explicit bound guards.

Position 1289 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

A Step procedure advances a deterministic modular LCG in an in out state, moves a bounded Level up or down, prints it, and returns a Boolean success. Step_Up is iterative rather than recursive: it keeps a bounded count of pending steps that starts at one, and on each attempt decrements it on success or increments it on failure (the iterative equivalent of the recursive scheme), looping until the count is zero. Guards before each increment and a fixed attempt cap produce a printed 'gave up' outcome when the documented limits are reached. About 55 lines.

## Proof obligations to watch

- **overflow**: The loop-carried pending-steps count and the level are bounded subtypes with an explicit guard before each increment, and hitting the bound gives a visible 'gave up' outcome rather than a silent change.
- **overflow**: The pseudo-random generator uses a modular type so wraparound is by definition, avoiding any overflow check.
- **termination**: Step_Up is a procedure so no termination check applies, and the attempt loop is a for loop with a fixed maximum anyway.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, procedures, while loops, for loops, modular types and 'Image of scalars.

## External effects

- **console output** (allowed): The simulation prints each climb or fall and the final level with Put_Line.

Assessed on 2026-10-15 against page revision 415315 of the [task](https://rosettacode.org/wiki/Stair-climbing_puzzle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
