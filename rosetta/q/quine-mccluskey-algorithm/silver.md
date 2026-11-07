# Quine–McCluskey algorithm

**Candidate: proofs plausibly discharge automatically.** All loops can be static-bound for loops over fixed-capacity arrays in procedures and the data is small and embedded, so no annotation is needed, but many guarded counters and nested loops make the proof shape delicate.

Position 850 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Represent each cube as a record of a value and a don't-care mask over at most 4 variables, held in fixed-capacity arrays with counts. Prime implicants come from repeated pairwise merging in a bounded for-loop pass structure, marking merged cubes and keeping unmarked ones. The minimal cover is found by exhaustively testing every subset of the primes with a ranged for loop, keeping the smallest subset covering all required minterms, and printing each term as a 0, 1 or X string built a character at a time. About 170 lines.

## Proof obligations to watch

- **index**: Cube lists are fixed-capacity arrays whose insertion is guarded by count < capacity, with a visible rejection outcome when full, so the index checks discharge from the guard.
- **overflow**: Counts, subset masks and bit values are declared as ranged subtypes bounded by the fixed variable limit (say 4 variables, 16 minterms, at most 16 primes), so the arithmetic stays within the type ranges.
- **termination**: The merge-until-fixpoint loop and the subset search are written as for loops with static bounds in procedures, so no variant is needed.
- **range**: Loop-carried values such as the best subset size and the covering flag are kept in types that hold every reachable value, and the exhaustive subset search is bounded by the prime capacity.
- **other**: The embedded example (minterms 1,2,5 and don't-cares 0,7) is validated against the variable and capacity limits, with a stated rejection outcome for larger functions, so the bounds do not quietly narrow the task.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, for loops, while loops, procedures, functions, case statements and Put without a newline.

## External effects

- **console output** (allowed): The minimal sum-of-products terms are printed as lines such as 0X0 and X01.

Assessed on 2026-10-15 against page revision 413871 of the [task](https://rosettacode.org/wiki/Quine%E2%80%93McCluskey_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
