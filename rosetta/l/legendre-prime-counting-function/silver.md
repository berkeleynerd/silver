# Legendre prime counting function

**Candidate: proofs plausibly discharge automatically.** All data is fixed-size arrays and ranged integers with explicit guards, and the recursion is replaced by an explicit stack in a procedure so no variant is needed, but the loop-carried stack top and signed accumulator need careful guard placement.

Position 275 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A Boolean array sieves primes up to 31622 into a constrained prime array with a count; for each n = 10^k (computed by repeated multiplication in a ranged subtype) a procedure evaluates phi(n,a) without recursion using an explicit stack array of (x, a, sign) triples popped in a while loop, stopping branches at a = 0 or x <= p_a and pushing the two children otherwise. Every push, prime lookup and accumulator update is guarded with a Reject outcome, and the result phi + a - 1 is printed with 'Image-based text and Put_Line. About 120 lines.

## Proof obligations to watch

- **overflow**: The signed accumulator of the explicit-stack phi evaluation is loop-carried with no invariant, so each addition is preceded by a guard against a wide ranged subtype bound that Rejects visibly, which never triggers since partial sums stay within about 1e9 in magnitude.
- **index**: The explicit stack top and the prime index a-1 are loop-carried, so each push is guarded by a capacity test (capacity 3500 exceeds the true maximum depth of about 3402) and each prime lookup by a range test on a, with Reject on failure.
- **overflow**: The sieve's i*i start and the product loop use values bounded by the sieve limit 31623, so subtype ranges and a guard i <= 177 before squaring discharge it.
- **division**: The divisor p_a is read from a prime array whose type is a subtype of 2..31623, so nonzero follows from the declared range.
- **termination**: All while loops live in procedures, which get no termination check, and the sieve and pi loops are for loops.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints pi(10^k) for k = 0 to 9 as text lines.

Assessed on 2026-10-15 against page revision 414306 of the [task](https://rosettacode.org/wiki/Legendre_prime_counting_function) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
