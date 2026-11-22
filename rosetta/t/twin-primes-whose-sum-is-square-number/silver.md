# Twin primes whose sum is square number

**Candidate: proofs likely to discharge automatically.** All arithmetic is bounded by static subtype ranges and every loop is a for loop, so checks follow from types and no variant or invariant is required. Only integers, for loops, a Boolean function and integer-to-text output must be added to Silver.

Position 884 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Since p+(p+2)=2(p+1) is a square only when p=2M^2-1, the program loops M over a subtype range 1..2236 and tests 2M^2-1 and 2M^2+1 for primality with a for-loop trial-division function (D in 2..3163, exit when D*D exceeds N). Qualifying pairs are printed with Put_Line and Integer'Image pieces, and the M bound is a static range keeping every product within Integer. About 45 lines.

## Proof obligations to watch

- **overflow**: D*D in trial division is bounded because D is a subtype range of at most 3163 and candidates stay under 10,000,001, so Integer cannot overflow.
- **termination**: Only for loops are used (with exit), so functions need no variant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions, 'Image of scalars, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints one line per qualifying twin-prime pair.

Assessed on 2026-10-15 against page revision 414558 of the [task](https://rosettacode.org/wiki/Twin_primes_whose_sum_is_square_number) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
