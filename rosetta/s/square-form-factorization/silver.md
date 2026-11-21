# Square form factorization

**Candidate: proofs plausibly discharge automatically.** Everything is integer arithmetic with fixed-size arrays and loops that can be capped without changing the required outcome, so no annotation is needed, but the loop-carried 62-bit coefficient updates need careful range guards to avoid overflow checks the provers cannot bound.

Position 432 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Embed the task's example Ns in a constant array of a 64-bit-range subtype, and run the four multiplier instances (1, 3, 5, 7, 11) sequentially in a procedure instead of threads, with the form (a, b, c) held in wide ranged variables. Integer square root is a bisection for loop over 32 bits, the principal-cycle search is a capped for loop with a fixed 32-entry circular queue of small coefficients, and the ambiguous-cycle walk is a capped loop that stops at the symmetry point and yields a factor via mod and division behind guards. Results print as "N = ..." and "f = ... N/f = ..." or "fail" via 'Image concatenation. About 230 lines.

## Proof obligations to watch

- **overflow**: The reduction step's products and the c update are loop-carried, so with no invariant they need explicit guards (e.g. compare q against a bound divided by a) that reject or fail the attempt visibly, and nonlinear provers may struggle.
- **range**: Form coefficients a, b, c must live in a wide subtype such as 0..2**62 and every update is guarded against leaving it, because only the type range is known after the first iteration.
- **division**: Divisions by a, the multiplier and the queue entries are each preceded by an explicit nonzero guard.
- **termination**: All searches (cycle walk, ambiguous-cycle walk, integer square root by bisection) use for loops with fixed iteration caps, and a cap hit produces the reported fail outcome.
- **index**: The 32-entry circular queue index is kept in range with mod and a ranged subtype, and the pro scan runs over the array's own range.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each N and its factor pair or a fail line with Put_Line.

Assessed on 2026-10-15 against page revision 413925 of the [task](https://rosettacode.org/wiki/Square_form_factorization) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
