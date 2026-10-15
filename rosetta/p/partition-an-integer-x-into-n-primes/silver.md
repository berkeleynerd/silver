# Partition an integer x into n primes

**Candidate: proofs plausibly discharge automatically.** All data are fixed-capacity arrays and bounded integer subtypes, and the search is an iterative loop in a procedure, so no variants or invariants are needed; the main work is placing guards on stack depth, sums and buffer positions.

Position 294 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Sieve primes up to 100000 into a Boolean array and collect them in a bounded prime table, embed the test (x, n) pairs in a constant array, and for each run an iterative backtracking search in a procedure with an explicit fixed-size stack of prime-table indices, trying ascending primes so the lexicographically lowest solution is found first. Pruning guards stop a branch when the next prime exceeds the remaining value, and the n=1 case checks primality of the remainder directly via the sieve. The result is formatted with 'Image into a bounded buffer and printed with Put_Line, or a 'not possible' line is printed when the search is exhausted. About 170 lines.

## Proof obligations to watch

- **index**: The explicit search stack and the prime-table cursor are loop-carried, so each use is preceded by a guard against the fixed capacity (24 levels, prime table size) and types bound the indices.
- **overflow**: Running sums and remaining-value counters are subtypes bounded by 100000 and are only updated after a guard compares them to the remaining target, so no overflow arises.
- **length**: The output line is assembled in a fixed buffer with a tracked write position, and each append is guarded by remaining capacity (about 200 characters for 24 primes), with a visible truncation or reject outcome otherwise.
- **termination**: The backtracking search is a while loop inside a procedure, so no termination check is generated; it is kept out of functions.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints one 'Partitioned X with N primes: p+q+...' line per embedded test case.

Assessed on 2026-10-15 against page revision 413834 of the [task](https://rosettacode.org/wiki/Partition_an_integer_x_into_n_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
