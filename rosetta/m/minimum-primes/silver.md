# Minimum primes

**Candidate: proofs plausibly discharge automatically.** Every check is bounded by declared integer ranges and for-loop indexes, but the prime search and trial division carry loop values through while loops that need guards and must sit in procedures, so discharge depends on careful program shape.

Position 905 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Embed the three five-element Integer arrays as constants, loop over index 1..5 with a for loop to take the max of each column, then a procedure searches upward from max for the least prime using trial division by odd divisors bounded by a ranged subtype. Results go into a five-element array and are rendered via integer image into a bounded buffer and printed with Put_Line. About 70 lines.

## Proof obligations to watch

- **termination**: The prime test and next-prime search use while loops, so they live in procedures (no termination check) rather than functions.
- **overflow**: The trial divisor d*d and the incrementing candidate are loop-carried, so values are held in a bounded subtype (for example 1 .. 10_000) and guards stop the loops before d*d or candidate+2 can exceed it.
- **range**: The search for the least prime at or above max needs a bounded outcome, so the candidate range includes a prime above 98 (101) and the loop exits with a visible rejection if the bound is hit.
- **length**: Output text is built from a bounded buffer with a fixed capacity sized for five numbers of at most three digits plus separators.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, functions, Boolean objects, Put without a newline, 'Image of scalars, string building and conditional expressions.

## External effects

- **console output** (allowed): Prints the resulting list of minimum primes.

Assessed on 2026-10-15 against page revision 412576 of the [task](https://rosettacode.org/wiki/Minimum_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
