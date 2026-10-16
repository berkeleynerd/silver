# Mutual recursion

**Candidate: proofs plausibly discharge automatically.** The task requires mutual recursion. Written as functions it would need variant annotations, but written as procedures it has no termination check, and the one non-routine range fact (the inner result is at most N) is covered by a visible guard that never fires. Discharge therefore depends on careful program shape rather than annotations.

Position 1564 in the [progression](../../progression.md#stage-36), in stage 36.

## Approach

F and M are mutually recursive procedures over a declared subtype 0..Max. Each takes N and returns its result R and an Ok flag through out parameters, and handles N = 0 directly. Otherwise it calls itself and its partner on N-1 and guards the subtraction with a check that the inner result is at most N. Main loops over 0..19 with for loops and prints each F and M value with 'Image and Put_Line, and it reports an internal error if Ok is ever False. About 55 lines.

## Proof obligations to watch

- **termination**: Mutually recursive functions would each need a Subprogram_Variant that Silver authors cannot write, so the program writes F and M as mutually recursive procedures with out parameters, which get no termination check.
- **range**: Without a postcondition the prover cannot know M(F(N-1)) <= N, so each procedure checks that the inner result is at most N before subtracting and otherwise sets an Ok out flag to False, which Main reports as an internal error. The guard never fires and does not change any required result.
- **initialization**: The R and Ok out parameters are given default values at the start of each procedure, so every early-exit path leaves them initialized.
- **stack**: Recursion depth grows linearly with N, but N is bounded by the embedded constant range 0..19, so the depth is fixed rather than input-dependent and stays within the sufficient-memory premise.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, for loops, procedures, recursive procedures and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the first values of the Female and Male sequences to standard output.

Assessed on 2026-10-15 against page revision 412936 of the [task](https://rosettacode.org/wiki/Mutual_recursion) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
