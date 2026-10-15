# Loops/N plus one half

**Candidate: proofs likely to discharge automatically.** Everything follows from a static for-loop range and a visible if guard, with no loop-carried state, so all checks and the Bronze-level checks discharge routinely; the only gaps are unterminated Put and integer 'Image output in Silver_IO.

Position 39 in the [progression](../../../progression.md#stage-3), in stage 3.

## Approach

A parameterless Main procedure runs a for loop over 1 .. 10 with a constant range, emitting the number via Put of its 'Image and then, guarded by if I < 10, a separate Put of ", " before ending with a line terminator. The loop index is a bounded for-loop variable, so no loop-carried values exist. About 12 lines.

## Language surface beyond today's Silver

Integers, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the comma-separated list 1 through 10 to standard output.

Assessed on 2026-10-15 against page revision 411531 of the [task](https://rosettacode.org/wiki/Loops/N_plus_one_half) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
