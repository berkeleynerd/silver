# Pancake numbers

**Candidate: proofs plausibly discharge automatically.** The search is bounded (at most 362880 states) and uses only for loops and a procedure-level while loop, so no annotation is needed, but the loop-carried rank arithmetic and large array indexing require carefully placed guards.

Position 474 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

For each n from 1 to 9, run a breadth-first search over all n! permutations of a fixed 9-element Digit array, starting from the sorted stack, using the Lehmer-code rank as the index into fixed-capacity visited, distance and queue arrays, and unranking dequeued states to apply the flips of prefixes 2..n. The deepest state found gives p(n) and its example stack, and each result line is built in a bounded String buffer with Image conversions and printed with Put_Line. Rank sums, queue positions and prefix lengths are guarded or typed to declared ranges so every check follows from types and local conditions. About 170 lines.

## Proof obligations to watch

- **overflow**: The permutation rank is a loop-carried sum, so each addition is guarded against a declared maximum of 362879 (9! - 1) with a visible rejection outcome, since GNATprove would otherwise know only the accumulator's type.
- **index**: Queue tail, head and rank indexes into the 362880-entry arrays are checked by guards just before use, and the queue cannot overflow because each state is enqueued at most once under a visited guard.
- **stack**: Several arrays of 362880 entries (visited, distance, queue, example) are about a few megabytes on the stack, which GNATprove does not check and Silver must treat as an environmental premise.
- **termination**: The breadth-first search uses a while loop inside a procedure, which gets no termination check, while rank and flip helpers use only for loops.
- **range**: Unranking uses division and mod by factorial constants held in a constant array, so divisors are statically non-zero and quotients are bounded by the digit subtype.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, for loops, while loops, procedures, functions, Boolean objects, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints one line per n from 1 to 9 giving p(n), an example start stack and the sorted target.

Assessed on 2026-10-15 against page revision 414660 of the [task](https://rosettacode.org/wiki/Pancake_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
