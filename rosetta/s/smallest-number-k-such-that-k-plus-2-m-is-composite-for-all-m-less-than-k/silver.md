# Smallest number k such that k+2^m is composite for all m less than k

**Candidate: proofs plausibly discharge automatically.** Everything is small bounded integer arithmetic with for loops over array ranges and one while loop in a procedure, so no annotation is needed, but shape-dependent range typing of residues and the 5000-bit numbers avoided via small-prime witnesses make discharge plausible rather than routine.

Position 233 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Build a constant-size prime table with a sieve in a Boolean array, then for each odd candidate k from 3 upward test m from 1 to k-1 by keeping, for every table prime, the residue of 2^m (doubled and reduced each step). For each m a for loop over the table looks for a prime p with (k + 2^m) mod p = 0 and k + 2^m greater than p, and the candidate is rejected at the first m with no witness; accepted values are printed with Put and 'Image until five are found or a documented candidate limit is hit. About 70 lines.

## Proof obligations to watch

- **overflow**: All arithmetic is on residues below a fixed prime bound (2^16) and k below a declared limit, so sums and doublings fit a 64-bit range type without any invariant.
- **index**: Prime-table and residue-table indexes come from for loops over the arrays' own ranges, while the candidate k and m are range-typed with the declared maximum.
- **termination**: The search for the fifth element is a while loop inside a procedure (no termination check), and it stops at a declared candidate limit that rejects further search visibly.
- **other**: Compositeness is witnessed by a divisor among a fixed table of small primes rather than a full primality test, so a true element lacking such a witness would be missed; the table bound must be documented and sized so the five known elements (773 to 5101) are covered.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The five sequence elements are printed on one line.

Assessed on 2026-10-15 against page revision 413915 of the [task](https://rosettacode.org/wiki/Smallest_number_k_such_that_k%2B2%5Em_is_composite_for_all_m_less_than_k) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
