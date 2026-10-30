# Greatest prime dividing the n-th cubefree number

**Candidate: proofs plausibly discharge automatically.** Trial division with ranged subtypes and guarded exponent and count updates keeps every check derivable from types and guards, but several loop-carried values need careful typing, so discharge is plausible rather than certain. No annotations, recursion or heap are needed, and the main new surface is integer arithmetic, loops, arrays and number formatting.

Position 251 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A for loop scans candidates 2 to a fixed bound of 200000; for each, a procedure with a nested for loop over divisors 2..500 strips each prime's powers with a while loop, reports non-cubefree if an exponent reaches 3, and tracks the largest prime factor (the leftover n above 1 counts as a prime). Cubefree hits are counted, the first 100 terms are stored in a fixed array, and rows of ten are formatted in a bounded string and printed, followed by the 1,000th, 10,000th and 100,000th terms captured at those counts. The 1 millionth and 10 millionth stretch terms are left out. About 90 lines.

## Proof obligations to watch

- **overflow**: Divisor squares and the counters stay inside ranged subtypes (divisor 2..500, candidate up to 200000), and the exponent counter is exited at 3, so each arithmetic check follows from type ranges.
- **index**: The 100-term result array is written only under a guard that the running count is below 100, since the count is a loop-carried value with only its type range known.
- **termination**: The exponent-stripping while loop is in a procedure so it needs no variant, and the outer scan is a for loop over a fixed candidate range.
- **range**: The running count and the largest-prime-factor variable are loop-carried, so each is declared with a range wide enough for its maximum and increments are guarded by the count limit.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 100 terms and the 1,000th, 10,000th and 100,000th terms.

Assessed on 2026-10-15 against page revision 414239 of the [task](https://rosettacode.org/wiki/Greatest_prime_dividing_the_n-th_cubefree_number) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
