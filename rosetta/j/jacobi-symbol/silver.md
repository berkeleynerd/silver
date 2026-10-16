# Jacobi symbol

**Candidate: proofs plausibly discharge automatically.** The algorithm is pure bounded integer arithmetic with a while loop inside a procedure, so termination is not checked and range and division checks follow from subtypes plus local guards; only careful guard placement in the loop-carried a, n values keeps it from being routine.

Position 392 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

A procedure Jacobi (A, N in; Result out) uses the standard reduction loop: reduce a mod n, strip factors of two while flipping the sign when n mod 8 is 3 or 5, then swap using quadratic reciprocity (flip when both are 3 mod 4), and return 0 when the final n is not 1. The main procedure loops over the odd n and a ranges from the task table, converts each symbol to a width-3 field in a bounded String buffer, and prints each row with Put and Put_Line. All values are in small declared subtypes with explicit positivity guards before every mod. About 80 lines.

## Proof obligations to watch

- **overflow**: Loop-carried a, n and the sign result live in small declared subtypes (for example 0..1000 and -1..1), so negation and mod cannot overflow once types bound them.
- **division**: Each mod or / is placed under an explicit n > 0 guard just before use, since no invariant can carry that fact across iterations.
- **termination**: The Euclid-style reduction loop lives in a procedure, which gets no termination check, so no variant is needed.
- **range**: After the swap step the new n must be positive, which is guarded by testing a /= 0 immediately before the swap rather than relying on a loop invariant.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, for loops, while loops, procedures, functions, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The program prints the Jacobi symbol table for odd n from 1 to 29 and a from 1 to 20.

Assessed on 2026-10-15 against page revision 413374 of the [task](https://rosettacode.org/wiki/Jacobi_symbol) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
