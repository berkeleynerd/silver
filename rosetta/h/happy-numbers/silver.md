# Happy numbers

**Candidate: proofs likely to discharge automatically.** All arithmetic is bounded by declared ranges and the iteration uses for loops with fixed caps inside a procedure, so no annotation is needed; the new surface is just integers, division, loops, a procedure and integer-to-text.

Position 190 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A subtype Small is range 0..999; procedure Is_Happy takes N and an out Boolean, and runs a for loop over a fixed step cap, each step replacing Current by the sum of squares of its three digits (computed with mod 10 and / 10 on straight-line digits, result range-bounded at 243), exiting with True at 1 and False if the cap ends without reaching 1. The main procedure loops N in 1 .. 100 (the first eight happy numbers end at 31), calls Is_Happy, and prints each happy number via Integer'Image with Put_Line, counting Found and exiting when Found reaches 8 (increment guarded by Found < 8). About 40 lines.

## Proof obligations to watch

- **overflow**: The digit-square sum is computed straight-line over three digits of a number typed 0..999, so the sum is bounded by 243 from types alone.
- **termination**: The per-number iteration is a for loop over a fixed step cap (for example 20 steps) with early exit, so no variant is needed; every candidate up to 100 reaches 1 or the 4-cycle well within the cap.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the first eight happy numbers, one per line.

Assessed on 2026-10-15 against page revision 415022 of the [task](https://rosettacode.org/wiki/Happy_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
