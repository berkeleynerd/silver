# Even numbers which cannot be expressed as the sum of two twin primes

**Candidate: proofs likely to discharge automatically.** Every loop is a for loop (sieve strides can be done as an inner for over multiples using guarded index arithmetic), all indexes and sums are bounded by declared ranges or guards, and no function needs termination variants, so proofs should discharge without annotations.

Position 890 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Sieve primes up to 5002 into a Boolean array with nested for loops, collect twin primes (n where n-2 or n+2 is prime, plus 1 for the second run) into a fixed-capacity array with a guarded count, then mark every sum <= 5000 in a Boolean array via a double for loop with an explicit sum guard. Finally print unmarked even numbers, building each output line in a bounded String buffer with Image conversion (and a per-line counter), plus the count, for both the with-1 and without-1 variants through one procedure taking a Boolean parameter. About 90 lines.

## Proof obligations to watch

- **index**: Array indices for the sieve, twin-prime table and sum-marking are all bounded by explicit guards (sum <= 5000, table count < capacity) or by for-loop ranges over the array's own range.
- **overflow**: All values are in subtype 0..10000 or small counters bounded by the table capacity, so sums of two entries stay far below Integer'Last.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the two lists of numbers that cannot be formed, with counts.

Assessed on 2026-10-15 against page revision 388682 of the [task](https://rosettacode.org/wiki/Even_numbers_which_cannot_be_expressed_as_the_sum_of_two_twin_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
