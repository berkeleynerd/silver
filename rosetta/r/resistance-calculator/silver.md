# Resistance calculator

**Candidate: proofs plausibly discharge automatically.** The task needs only fixed-size arrays, bounded float arithmetic and iterative traversal, with no annotations required, but float range guards and fixed-width decimal formatting make discharge depend on careful program shape.

Position 1192 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

The network is an embedded array of nodes in post-order (kind Leaf, Series or Parallel, left and right indices, resistance, voltage) built from the task's RPN sequence as constant data, so no parsing is needed. A for loop over nodes computes resistances bottom-up, a reverse for loop distributes voltage top-down, and a procedure with an explicit index stack and while loop prints each node in pre-order with its depth-based tree prefix, resistance, voltage, current and power formatted to three decimals. About 170 lines.

## Proof obligations to watch

- **floating point**: Parallel resistance computes 1/(1/a+1/b) and the voltage divider ra/(ra+rb)*v, which discharge only if resistances are a bounded float subtype with a positive lower bound and voltages are bounded, so all intermediates are range-guarded.
- **division**: Divisions by resistance and by the sum of resistances are safe only because every leaf resistance is a constant at least 1.0 and equivalent resistances are guarded by explicit positivity checks that reject otherwise.
- **index**: Tree children, the pre-order stack and node counts are bounded by a fixed node capacity, and stack pushes are guarded by explicit capacity checks before each use.
- **termination**: Pre-order printing needs a while loop with an explicit stack, which is safe because it lives in a procedure (no termination check) and recursion is avoided.
- **overflow**: Bottom-up and top-down passes are plain for loops over the node array, with float values clamped by type ranges so no overflow check depends on loop-carried facts.
- **other**: Formatting floats to exactly three decimals with column alignment requires a bounded rounding-and-digit routine with guarded range checks on the scaled integer conversion.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, enumerations, floating point, floating-point images, arrays, records, string building, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The report table is printed line by line to standard output.

Assessed on 2026-10-15 against page revision 409958 of the [task](https://rosettacode.org/wiki/Resistance_calculator) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
