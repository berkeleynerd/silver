# Erdös-Selfridge categorization of primes

**Candidate: proofs plausibly discharge automatically.** Every check follows from subtype-bounded indices and guarded divisions in procedure loops with no recursion, but several loop-carried values need careful range typing and the large fixed tables raise a stack-size premise. No annotation is needed, so discharge is plausible rather than routine.

Position 275 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A Boolean sieve array and a category array (subtype 0..12) are sized to the millionth prime, 15,485,863, plus one, and filled by for loops. Primes are processed in increasing order, and for each prime p, p+1 is factored by trial division inside a while loop in a procedure, taking the maximum category of prime factors above 3 from the table (guarded index) and storing max plus one. Per-category first, last and count arrays are updated and printed with Put_Line using 'Image concatenation, for the first 200 and then the first million primes. About 110 lines.

## Proof obligations to watch

- **index**: Every table access (sieve, category table, divisor) uses an index of a subtype bounded by the sieve limit, with an explicit guard before looking up a factor's category.
- **overflow**: Counters, n and divisors are subtypes bounded by the 15,485,864 sieve limit and one million, so additions and divisions stay in range, and the category increment is guarded at 12 with a visible rejection.
- **termination**: All loops are in procedures, where no termination check applies, and the factoring loop strictly divides n by a divisor of at least 2.
- **stack**: A sieve of about 16 million Booleans and category bytes is a fixed-size array whose stack or static storage exhaustion lies outside the proof, treated as an environmental premise.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the 200-prime category listing and the per-category first, last and count summary lines.

Assessed on 2026-10-15 against page revision 415458 of the [task](https://rosettacode.org/wiki/Erd%C3%B6s-Selfridge_categorization_of_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
