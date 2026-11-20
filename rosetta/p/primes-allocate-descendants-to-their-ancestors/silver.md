# Primes - allocate descendants to their ancestors

**Candidate: proofs plausibly discharge automatically.** All data is in bounded arrays with for-loop indexes, and the only loop-carried arithmetic (products and fill counters) is covered by explicit capacity and overflow guards, so it should prove without annotations but needs careful shape.

Position 429 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Primes below 100 and a parent table (sum of prime factors by trial division) are computed in bounded arrays; a first pass counts multisets of primes per sum, prefix sums give offsets into one fixed-capacity flat Long_Long_Integer array, and a second pass fills descendants by multiplying earlier values by each prime, with guards on capacity and overflow. Ancestors come from walking the parent table in a bounded for loop (stopping at primes and at 4), the 557 descendants of 46 are insertion-sorted and printed through a small bounded text buffer with scalar-image, and the grand total of 546,986 is printed at the end. About 190 lines.

## Proof obligations to watch

- **overflow**: Each descendant is prime times an earlier value, so the program guards with a check that the value is at most the 64-bit maximum divided by the prime and takes a specified Reject path otherwise, though the guard never fires because the largest value is 3**33.
- **index**: Flat per-sum storage uses offsets and fill counts that are loop-carried, so each store is preceded by an explicit capacity guard that rejects the run if the fixed capacity (about 600000 values) would be exceeded.
- **termination**: The ancestor chain is walked in a procedure with a for loop bounded by 99 steps and a special case for 4 (whose parent is itself), so no function needs a variant.
- **other**: The program must sort the 557 descendants of 46 using an insertion sort in a procedure whose indexes come from for loops over the array range, which is routine but loop-carried comparisons need guards.
- **stack**: A roughly 5 MB value array is large for a Main-local object, but stack exhaustion is an environmental premise rather than a proof obligation.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the level, ancestors, descendant counts and lists for the chosen parents and the grand total.

Assessed on 2026-10-15 against page revision 414417 of the [task](https://rosettacode.org/wiki/Primes_-_allocate_descendants_to_their_ancestors) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
