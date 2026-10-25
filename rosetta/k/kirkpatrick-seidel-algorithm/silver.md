# Kirkpatrick–Seidel algorithm

**Candidate: proofs plausibly discharge automatically.** Everything uses bounded integer coordinates, fixed arrays and explicit guarded stacks inside procedures, so checks follow from types and guards, but the nonlinear cross products and loop-carried stack indexes require careful program shape.

Position 419 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Points are held in two parallel fixed-capacity arrays of a small ranged coordinate subtype with embedded sample data. A procedure sorts by x then y with bounded for loops, then computes upper and lower hulls by an iterative divide-and-conquer on an explicit interval stack (finding the bridge over the median x in each interval with integer cross products), appending hull vertices into a bounded output array. Guards before every push, pop and index keep the stacks in range, and the hull points are printed as text lines using Integer'Image. About 170 lines.

## Proof obligations to watch

- **index**: The hull stack top and the explicit divide-and-conquer interval stack are loop-carried indexes, so each push and pop is guarded by a capacity or non-empty test just before use.
- **overflow**: Cross products and median/bridge slope comparisons are nonlinear, but coordinates are a declared small range subtype so every product and sum stays inside Integer.
- **termination**: The while loops that pop non-left turns and drain the interval stack live in procedures, which get no termination check, so no variant is needed.
- **other**: Replacing recursion with an explicit bounded stack keeps the divide-and-conquer shape without stack-depth risk, but the stack capacity must be guarded and overflow of it must have a visible rejected outcome.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars and string building.

## External effects

- **console output** (allowed): The program prints the embedded input points and the resulting hull points as text lines.

Assessed on 2026-10-15 against page revision 414285 of the [task](https://rosettacode.org/wiki/Kirkpatrick%E2%80%93Seidel_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
