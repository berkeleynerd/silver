# Prime conspiracy

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed array bounds, ranged digit subtypes and guards placed before the increments, with no recursion or annotations needed. Plausible rather than likely because the sieve stride and the many loop-carried counters need careful guards, and the large array leans on the memory premise.

Position 713 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Run a Sieve of Eratosthenes into a fixed Boolean array sized to the 1,000,000th prime (15,485,863), using a for loop for the base primes and a guarded while loop for the multiples. A second pass walks the sieve, tracking the previous prime's last digit and incrementing a 10x10 ranged count table until 1,000,000 primes are seen. Then nested for loops over digit pairs print each nonzero transition with its count and an integer two-decimal percentage built from 'Image text in a procedure. About 90 lines.

## Proof obligations to watch

- **overflow**: The 100-cell transition counters and the running prime count are loop-carried, so each increment is guarded by a test against the 1,000,000 limit (the prime count is also tested before it advances) to keep them in range.
- **index**: Sieve strides use a while loop with the guard j <= Limit - i before j := j + i, so the index stays within the array bounds and the addition cannot overflow.
- **overflow**: The marking start i*i is computed only for i up to 3936 (or in Long_Long_Integer), so the product stays far below the type limit.
- **overflow**: The percentage count*10000/total uses counts at most 1,000,000 and a positive total, so the product and the division are bounded by types.
- **heap**: The 15.5-million-entry Boolean sieve is a large static array whose memory is not proved, which is covered by the fixed environmental memory premise.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, string building, 'Image of scalars, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the header and one line per nonzero transition with its count and percentage.

Assessed on 2026-10-15 against page revision 413854 of the [task](https://rosettacode.org/wiki/Prime_conspiracy) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
