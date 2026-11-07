# Pisano period

**Candidate: proofs plausibly discharge automatically.** Every operand is bounded by small declared ranges (m at most 180, periods at most a few hundred), so loop-carried values need only a few range guards and all loops can be for loops or procedure loops with no annotations, though the lcm and power arithmetic need careful guarded shape.

Position 417 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Use ranged subtypes (modulus 1..180, a 64-bit Period type with a stated cap) and small fixed arrays for prime factors and exponents. Pisano of a prime comes from a for loop over a bounded step count (at most 6m) that advances the Fibonacci pair mod m and returns when the pair is 0,1; pisano(m) factors m by a for loop over candidate divisors, multiplies by p**(k-1) in a guarded loop, and folds with a gcd-based lcm. Main loops over 2..14, 2..179 and 1..180, printing via Put/Put_Line with 'Image, and rejects with a specified message if any guard fails. About 150 lines.

## Proof obligations to watch

- **overflow**: The lcm product and the p**(k-1) multiplication are loop-carried, so they use a bounded Period subtype in 64-bit arithmetic and an explicit guard that rejects any result above the documented limit before assignment.
- **index**: The prime-factor count is loop-carried, so a guard on count against the array capacity (at most 8 distinct primes for values up to 180) precedes each store, with a visible rejection outcome otherwise.
- **termination**: Trial division, the Fibonacci cycle search and Euclid's gcd are written as for loops with early exit or as procedures, because while loops inside functions would need a variant.
- **range**: The Fibonacci pair modulo m stays below m through the type range of the loop-carried variables plus a guard that m is at least 1 before the mod, so the sum a+b cannot overflow.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, functions, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the pisanoPrime(p,2) lines, the pisanoPrime(p,1) lines and the 180 pisano values as text.

Assessed on 2026-10-15 against page revision 414401 of the [task](https://rosettacode.org/wiki/Pisano_period) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
