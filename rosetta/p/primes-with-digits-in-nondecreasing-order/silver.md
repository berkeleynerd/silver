# Primes with digits in nondecreasing order

**Candidate: proofs likely to discharge automatically.** All values are bounded by the declared 2..999 range and every loop is a for loop over a static range, so the division, range and overflow checks follow from types and no annotation is needed.

Position 123 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Main loops N over a subtype range 2..999; for each N a for loop over divisors 2..N-1 sets a Boolean Is_Prime flag using N mod D, and a second step extracts the three digits via N / 100, (N / 10) mod 10 and N mod 10 into small ranged subtypes and compares them with if conditions. Qualifying primes are printed one per line with Put_Line of the trimmed Integer'Image, with no recursion, no while loops and no input. About 32 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each qualifying prime with Put_Line.

Assessed on 2026-10-15 against page revision 395676 of the [task](https://rosettacode.org/wiki/Primes_with_digits_in_nondecreasing_order) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
