# Vampire number

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded by declared ranges and divisors are provably nonzero, with fixed-count for loops inside procedures, so the proofs should go through, but the loop-carried digit counters and the 64-bit product bounds need careful guards.

Position 948 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Represent numbers as Long_Long_Integer in a bounded subtype, with a procedure that counts decimal digits into a 0..9 array via a fixed-count for loop and compares two such arrays for the multiset test. For the first 25, loop candidates over the 4-digit and 6-digit ranges, and for each try fangs f from 10^(h-1) up to the square root bound, accepting when N mod f = 0, the cofactor has h digits, not both end in zero, and the digit multisets of f and N/f together equal that of N. The three listed 14-digit numbers use the same check with 7-digit fangs, printing fang pairs or a not-a-vampire message through 'Image string building. About 150 lines.

## Proof obligations to watch

- **overflow**: Products and digit-concatenation stay within 64-bit Long_Long_Integer because the candidate number is capped near 1.7e13 by subtype ranges and the fang range is bounded by a guard before multiplying.
- **overflow**: Digit-count increments in a loop-carried array need a guard such as counts(d) < limit before adding one, since no invariant can bound them, and the guard never fires for numbers of at most 14 digits.
- **index**: Digit indexes come from mod 10 on a non-negative value, so the 0..9 array index check follows from the type range once the dividend is a natural subtype.
- **termination**: Every loop sits in a procedure, using for loops with fixed digit counts instead of while loops to extract digits, so no variant is needed.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints each vampire number with its fang pairs, and the verdict for the three given numbers, to standard output.

Assessed on 2026-10-15 against page revision 414568 of the [task](https://rosettacode.org/wiki/Vampire_number) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
