# Resistor mesh

**Candidate: proofs plausibly discharge automatically.** The task needs only a fixed-size grid and a bounded float relaxation, which is feasible with explicit bound guards and an iteration cap, but float range checks on loop-carried voltages and the convergence tolerance make discharge depend on careful program shape and on formatting a float to text.

Position 1064 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Store node voltages in a 10x10 array of a bounded float subtype, fix A at (2,2) to +1 and B at (7,8) to -1, and repeat Jacobi/Gauss-Seidel sweeps in a for loop with a fixed cap, each sweep averaging guarded neighbours and rejecting any out-of-bound value. After convergence (or rejection at the cap) compute the net current at A and B from the neighbour differences and print 4/(IA-IB) as text with a guard on the denominator. About 80 lines.

## Proof obligations to watch

- **floating point**: Voltages updated by relaxation are loop-carried floats with no invariant, so each new value is range-checked by an explicit guard that rejects the run if it leaves a declared bound, and the neighbour sums are then bounded by that subtype.
- **termination**: The relaxation runs as a for loop over a fixed iteration cap inside a procedure, with early exit on convergence, so no variant is needed and non-convergence has a specified rejection outcome.
- **division**: The divisor is a neighbour count of 2, 3 or 4 taken from fixed edge tests, and the final division by the current difference is guarded against zero with a reject outcome.
- **range**: Array indices i-1 and i+1 are used only under explicit boundary tests just before the access, so index checks discharge.

## Language surface recorded by this assessment

Integers, ranged subtypes, floating point, multidimensional arrays, for loops, while loops, procedures, floating-point images, Put without a newline, Boolean objects and functions.

## External effects

- **console output** (allowed): The program prints the computed resistance (about 1.608991) as one line of text.

Assessed on 2026-10-15 against page revision 414443 of the [task](https://rosettacode.org/wiki/Resistor_mesh) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
