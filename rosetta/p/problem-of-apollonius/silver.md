# Problem of Apollonius

**Candidate: proofs plausibly discharge automatically.** The algorithm is straight-line floating-point arithmetic with no loops or recursion, so termination and indexing are trivial, but proving no overflow, no division by zero and a nonnegative sqrt argument through degree-4 nonlinear expressions depends on bounded input ranges and many guards, hence plausible rather than likely.

Position 1107 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed the three example circles as record constants with bounded float components, and write one procedure Solve (Ok out Boolean, Result out Circle) taking tangency signs as +1.0/-1.0 constants, called once for all-external and once for all-internal. The procedure follows the algebraic solution with straight-line constant computations, guarding each divisor against zero and the discriminant against negative values, and reports failure otherwise. Results are formatted to three decimals and printed with Put_Line/Put. About 130 lines.

## Proof obligations to watch

- **floating point**: Every Long_Float operation needs a no-overflow and finite-result proof, which the program gets by declaring coordinates and radii as a bounded range subtype and checking intermediate quantities against bounds before use, though the nonlinear products (up to degree 4 in the discriminant) make the provers work hard.
- **division**: The divisions by V11, V21, W22 and 2.0*A are each preceded by an explicit test that the divisor is nonzero, with a specified rejection message (no solution or degenerate input) if it is zero.
- **range**: The square root needs a nonnegative argument, so a guard on the discriminant D prints a specified 'no real solution' outcome when D is negative.
- **overflow**: Products of values up to the bound can exceed the float range unless each intermediate is guarded or the input subtype is small enough (for example magnitude at most 1000.0), which restricts the domain only by a documented limit.

## Language surface beyond today's Silver

Floating point, floating-point images, records, ranged subtypes, Boolean objects, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the two solution circles (center x, y and radius) to standard output.

Assessed on 2026-10-15 against page revision 412330 of the [task](https://rosettacode.org/wiki/Problem_of_Apollonius) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
