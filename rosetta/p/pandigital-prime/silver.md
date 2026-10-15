# Pandigital prime

**Candidate: proofs likely to discharge automatically.** Every loop is a bounded for loop and all values have declared ranges, so overflow, index and range checks follow from types and no variant is needed. The only non-routine point is the nonlinear d*d, which declared bounds keep small.

Position 784 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

A function Is_Pandigital takes a candidate in a declared range 0..99999999 and a digit count, extracts exactly that many digits in a for loop using mod and / into a Boolean array indexed 0..9, and rejects any repeated digit. A function Is_Prime does trial division in a for loop over divisors 2..10000 with an explicit d*d <= n guard before exit. Main procedures loop downward with a for loop in reverse from 7654321 for the 1..7 case and from 76543210 for the 0..7 case, print the first hit with 'Image, and print a fixed message if none is found. About 70 lines.

## Proof obligations to watch

- **overflow**: The trial-divisor square d*d is computed only for a divisor type bounded to 1..10000 and in a candidate type bounded to 0..99999999, so the product cannot overflow.
- **index**: Digit values come from mod 10 on a non-negative ranged value so they lie in 0..9, which matches the Boolean seen-array index range.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, functions, 'Image of scalars, string building and case statements.

## External effects

- **console output** (allowed): Prints the two largest pandigital primes with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 407662 of the [task](https://rosettacode.org/wiki/Pandigital_prime) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
