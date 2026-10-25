# Arithmetic-geometric mean

**Candidate: proofs plausibly discharge automatically.** The task needs only bounded floating-point arithmetic, Sqrt and a fixed-count loop, so checks reduce to range and non-negativity facts, but float range reasoning and the admitted Sqrt contract make discharge depend on careful typing.

Position 1033 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Declare a bounded non-negative floating-point subtype and a function AGM that runs a fixed number of for-loop rounds, each computing the arithmetic mean and the square root of the product with the admitted elementary Sqrt, guarded so the operands stay non-negative and in range. The main procedure computes the AGM of 1.0 and 1/Sqrt(2.0) and prints it through a float-to-text image with Put_Line. About 30 lines.

## Proof obligations to watch

- **floating point**: Sqrt needs a non-negative argument and its result must stay in the declared range, which holds when the operands are typed in a bounded non-negative float range and the admitted Sqrt contract is strong enough.
- **range**: Assigning (A+G)/2 and Sqrt(A*G) back to range-limited loop-carried variables relies on provers bounding float products, so guards or a wide-enough range subtype are needed.
- **termination**: A for loop with a fixed iteration count (for example 10 rounds, ample for convergence) replaces the epsilon-driven loop, so termination is automatic in a function.

## Language surface recorded by this assessment

Floating point, ranged subtypes, for loops, functions and floating-point images.

## External effects

- **console output** (allowed): Prints the computed mean of 1 and 1/sqrt(2) to standard output.

Assessed on 2026-10-15 against page revision 415338 of the [task](https://rosettacode.org/wiki/Arithmetic-geometric_mean) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
