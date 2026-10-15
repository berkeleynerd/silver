# Anonymous recursion

**Candidate: proofs likely to discharge automatically.** The task requires recursion, but a nested recursive procedure with an out parameter avoids the termination-check problem a recursive function would have. Every arithmetic check follows from the declared ranges plus guards just before each operation, and the depth is statically bounded by the embedded test range.

Position 1563 in the [progression](../../progression.md#stage-36), in stage 36.

## Approach

Main contains a public-facing procedure Fib (X : Integer) that first tests X < 0 and prints a rejection message. Otherwise it calls a nested recursive procedure Actual_Fib (N : Natural; Result : out Value; Ok : out Boolean), where Value is range 0 .. 2**61, which returns N when N < 2, else recurses on N - 1 and N - 2 and adds the results under an explicit upper-bound guard. A for loop over embedded sample arguments (for example -2 .. 30) drives it and prints each result with 'Image. About 45 lines.

## Proof obligations to watch

- **overflow**: With no postcondition the prover knows the recursive results only by their type (0 .. 2**61), so their sum fits the 64-bit base type and a guard against the type's upper bound comes just before the assignment; if it fails, an Ok flag is cleared and a visible overflow message is printed.
- **range**: N - 1 and N - 2 are computed only on the branch guarded by N >= 2, so they stay in Natural.
- **termination**: The recursion is written as a nested procedure with an out parameter, which gets no termination check, so no Subprogram_Variant is needed.
- **stack**: Recursion depth is at most the static upper bound of the embedded test range (for example 30), so it stays within the fixed-memory premise even though GNATprove does not check it.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, for loops, procedures, recursive procedures and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints each Fibonacci result and a rejection message for negative arguments with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 412646 of the [task](https://rosettacode.org/wiki/Anonymous_recursion) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
