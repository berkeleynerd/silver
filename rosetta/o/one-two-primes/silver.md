# One-two primes

**Candidate: proofs plausibly discharge automatically.** Every check follows from array ranges and bounded remainder arithmetic, but 20-digit values exceed 64 bits so the work rides on digit-array or big-number handling in loops, which makes it plausible rather than likely.

Position 1363 in the [progression](../../progression.md#stage-24), in stage 24, which adds big numbers.

## Approach

For each length n from 1 to 20, enumerate candidates over digits 1 and 2 in increasing order with a binary odometer held in a fixed 20-digit array, and test each by trial division using long division of the digit array by bounded 64-bit divisors, stopping at the first prime. The program prints each term via a fixed buffer and Put_Line, with guards on carry and divisor bounds, and the stretch part is omitted as optional. About 90 lines.

## Proof obligations to watch

- **overflow**: Terms of 20 digits exceed 64 bits, so candidates are fixed-capacity digit arrays and the remainder step (rem*10+d) mod p is safe only because the divisor type is bounded so rem*10+9 fits in 64 bits.
- **termination**: The candidate search and divisor loop are while loops in procedures, which get no termination check, and each is bounded by a fixed count such as 2**n candidates and a divisor ceiling.
- **index**: Candidate digit arrays are indexed by for loops over the array's own range, and the odometer increment uses guards on the digit index so carry never leaves bounds.
- **other**: Trial division of 20-digit candidates up to about 1.5e10 is correct but slow, so a fixed-capacity big-number Miller-Rabin library would be needed to run fast and the stretch to 2000 digits is out of scope.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string building, 'Image of scalars, for loops, while loops, procedures, functions and big numbers.

## External effects

- **console output** (allowed): Prints the 20 terms, one per line.

Assessed on 2026-10-15 against page revision 413819 of the [task](https://rosettacode.org/wiki/One-two_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
