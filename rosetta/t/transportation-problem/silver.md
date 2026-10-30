# Transportation problem

**Candidate: proofs plausibly discharge automatically.** The task is plain integer array work with while loops confined to procedures and fixed bounds, so no annotation is needed, but many loop-carried potentials, indices and quantities each need a careful guard to discharge without invariants.

Position 747 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed the 2x3 example (supply, demand, integer cost matrix) as constants in bounded arrays with a fixed maximum size plus room for a dummy row or column; build the initial plan with the north-west corner rule in for loops, then iterate a MODI loop in procedures: compute potentials over the basis by repeated sweeps, find the most negative reduced cost, trace the redistribution cycle with array-based index chains, shift the minimum quantity, and stop when no negative reduced cost remains. All indices and quantities use bounded subtypes with guards before every arithmetic update, and the final plan is formatted into bounded text lines and printed. About 260 lines.

## Proof obligations to watch

- **overflow**: Potentials u(i)=cost-v(j) are loop-carried and only bounded by their type, so each is computed in a wide integer type with a guard that rejects out-of-range values with a visible outcome.
- **index**: Cycle-search and basis-tree walks use computed row and column indices, which are discharged by declaring them in subtypes of the matrix bounds and guarding before each use.
- **range**: Pivot updates of shipment quantities add and subtract the minimum along the cycle, so quantities are kept in a bounded subtype and each update is preceded by an explicit range guard.
- **termination**: The stepping loop, potential propagation and cycle search are all while loops inside procedures (never functions), so no termination check arises, and an iteration cap with a visible reject outcome bounds them.
- **initialization**: The plan, potentials and visited-flag arrays are fully initialized by aggregates or for loops before the while loops read them.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The optimal plan matrix (and total cost) is printed to standard output.

Assessed on 2026-10-15 against page revision 380907 of the [task](https://rosettacode.org/wiki/Transportation_problem) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
