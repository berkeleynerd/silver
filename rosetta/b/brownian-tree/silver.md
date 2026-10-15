# Brownian tree

**Candidate: proofs plausibly discharge automatically.** Every index and range check follows from the field's subtypes and a border guard placed before each neighbour access and step, and no loop-carried fact needs an invariant, but the walk and generator arithmetic need careful shaping. It is plausible rather than likely because of the nested loop-carried coordinates and the modular arithmetic.

Position 1188 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

A constrained 2D Boolean array (for example 40 by 24) holds the tree, with a fixed seed in the centre and a modular-type LCG supplying the coordinates and directions. A for loop over a fixed particle count launches each particle at a pseudo-random cell; a bounded walk loop checks the border, stops when a neighbour is set, and otherwise steps by a case on a random direction. The field is then printed as rows of characters built in a fixed-length string with Put_Line. About 110 lines.

## Proof obligations to watch

- **overflow**: The generator state is a modular type (for example a linear congruential generator in a 32-bit modular type), so wraparound is defined and a range-reduction mod gives a result inside the field bounds by its type.
- **index**: Walker coordinates are subtypes of the field range and a guard that keeps the walker off the border runs just before each neighbour access and each step, so the +1 and -1 index and range checks discharge.
- **termination**: All loops live in procedures, which get no termination check, and the walk is bounded by a for-loop step budget per particle so the program also finishes; a particle that exhausts its budget is discarded in a specified way.
- **other**: Each particle walk reassigns the coordinates in a loop, so the border guard is re-tested every iteration and the range check on the stepped coordinate relies on that guard rather than on an invariant.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, records, for loops, while loops, case statements, procedures, functions, string building and Put without a newline.

## External effects

- **console output** (allowed): The tree is drawn as text art on standard output, which meets the task without a display.

Assessed on 2026-10-15 against page revision 415283 of the [task](https://rosettacode.org/wiki/Brownian_tree) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
