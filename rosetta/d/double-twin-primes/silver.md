# Double twin primes

**Candidate: proofs likely to discharge automatically.** All arithmetic is bounded by the constant limit 1000, loops are for loops over static ranges, and nothing needs a loop invariant or variant, so the proofs should discharge from types and ranges.

Position 201 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Use a Boolean array indexed 2..1000 filled by a nested for-loop sieve (marking multiples with a stepped inner loop written as a multiplication index with a guard), so no function-level while loops are needed. A for loop over I in 3..992 then checks odd I with Sieve(I), Sieve(I+2), Sieve(I+6) and Sieve(I+8) and prints the quadruple with Put_Line, building the line from 'Image of each number. About 45 lines.

## Proof obligations to watch

- **overflow**: Trial-division squares and candidate+8 stay far below the limits of a subtype bounded to 1000, so the checks follow from types and a guard before the array access.
- **index**: The scan loop runs only to 992 so I+8 stays within the 2..1000 array range, which is a static bound.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each double twin prime quadruple, one per line.

Assessed on 2026-10-15 against page revision 409007 of the [task](https://rosettacode.org/wiki/Double_twin_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
