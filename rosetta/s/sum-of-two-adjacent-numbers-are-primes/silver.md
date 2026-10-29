# Sum of two adjacent numbers are primes

**Candidate: proofs likely to discharge automatically.** Fixed small ranges, for loops and a guarded counter mean every overflow, range and division check follows from types and static bounds with no loop invariant needed.

Position 129 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A Main procedure loops n over the constant range 1..40 (the 20th qualifying n is 36), computes the sum 2n+1 in a range-limited subtype, and tests primality with an inner for loop over divisors 2..sum-1 using mod and a Boolean flag. A counter capped at 20 (guarded by count < 20 before incrementing) gates printing each line as n, n+1 and the sum converted to text and concatenated. The extra-credit ten-millionth sum is optional and omitted, so no big bounds are needed. About 35 lines.

## Proof obligations to watch

- **overflow**: All values are bounded by the declared range 1..40 for n and 81 for the sum, so every addition and multiplication discharges from types.
- **length**: Each output line is built from three Integer'Image texts with fixed literals, whose maximum length is bounded by the declared subtype ranges so concatenation fits the bounded buffer.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the 20 lines of the form 'n + n+1 = prime' with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 397683 of the [task](https://rosettacode.org/wiki/Sum_of_two_adjacent_numbers_are_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
