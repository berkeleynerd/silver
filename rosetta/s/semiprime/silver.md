# Semiprime

**Candidate: proofs likely to discharge automatically.** Every loop is a for loop over a static range, so the functions terminate without variants, and all arithmetic is bounded by a small declared subtype so overflow, range and division checks follow from types and loop ranges. No loop-carried value feeds a later check, so no invariant is required.

Position 337 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Declare a subtype Candidate of Integer range 1 .. 2000, a Boolean function Is_Prime that tests N > 1 and trial-divides with a for loop over 2 .. N - 1, and a function Is_Semiprime that loops D over 2 .. N - 1 and reports true when N mod D = 0 and both D and N / D are prime. A main procedure loops over 1 .. 99 and 1675 .. 1680, printing qualifying numbers with Put and Integer'Image, and ends each range with a newline. About 50 lines.

## Proof obligations to watch

- **termination**: Functions contain only for loops, which terminate on their own, so no variant is needed and no while loop or recursion is used.
- **division**: Divisors come from a for loop over 2 .. N so the divisor is never zero, and the quotient stays within the bounded Candidate subtype.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the semiprimes below 100 and those from 1675 to 1680 as space-separated lines.

Assessed on 2026-10-15 against page revision 414757 of the [task](https://rosettacode.org/wiki/Semiprime) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
