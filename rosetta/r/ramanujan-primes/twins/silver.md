# Ramanujan primes/twins

**Candidate: proofs plausibly discharge automatically.** Everything is integer arithmetic over bounded ranges with guards before each loop-carried index or increment, and nothing needs a variant or invariant, but the large array and many loop-carried values make discharge depend on careful program shape.

Position 255 in the [progression](../../../progression.md#stage-7), in stage 7.

## Approach

Sieve of Eratosthenes into a fixed-capacity Boolean array, then a prefix prime-count array in a procedure, using while loops with explicit bound guards. Scan downward from the largest even bound, using a decreasing remaining counter n so that pi(x) - pi(x/2) < n identifies each Ramanujan prime, and count those whose neighbor from the previous find differs by 2. Print the count with a fixed-capacity image concatenation, and print a specified message if the fixed limit proves too small. About 80 lines.

## Proof obligations to watch

- **overflow**: Sieve strides, squares of candidate primes and prefix counts are held in ranges typed to the fixed limit, and each loop-carried increment is guarded by a comparison against the limit just before use.
- **index**: Sieve and pi-array indexes are loop-carried while-loop values, so each access is preceded by an explicit bound guard (q <= Limit) and the halving index is bounded by its subtype.
- **heap**: A static array of tens of millions of counters is a large fixed resource limit, with the limit chosen from the known size of the millionth Ramanujan prime and documented as a premise.
- **termination**: All while loops live in procedures, which get no termination check, and the floating-point log bound is replaced by a literal constant so no floating point is needed.
- **other**: The scan for each Ramanujan prime must stop after exactly one million found; the counter is guarded and a visible Reject-style message is printed if the fixed limit is exhausted before then.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints one line stating the twin count and the number of Ramanujan primes examined.

Assessed on 2026-10-15 against page revision 413873 of the [task](https://rosettacode.org/wiki/Ramanujan_primes/twins) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
