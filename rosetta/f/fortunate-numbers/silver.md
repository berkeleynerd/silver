# Fortunate numbers

**Candidate: proofs plausibly discharge automatically.** All values are bounded by static ranges and explicit caps (primorial of 9 is about 2.2e8, m below a few hundred), so checks follow from subtypes and guards, but several loop-carried accumulators and nested primality loops need careful shaping.

Position 399 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Compute primorial(n) for n=1..9 iteratively with the next prime found by a trial-division procedure over a bounded Long_Long_Integer subtype, then for each n search odd m from 3 upward with a capped while loop in a procedure until primorial+m is prime, rejecting if the cap is hit. Insert each m into a fixed array of 16 Naturals only if not already present (linear scan, count-guarded), sort with a bounded insertion or bubble sort using for loops over the array's range, and print the first 8 with Integer'Image via Put_Line. About 90 lines.

## Proof obligations to watch

- **overflow**: Primorial accumulation in a loop is loop-carried, so the program multiplies a 64-bit accumulator only after a guard that the product stays under a fixed bound, with n limited to 9 or so primes, and the primorial plus m stays within the subtype range.
- **termination**: The search for m and the trial-division primality test live in procedures using while or bounded for loops with an explicit cap (m at most a fixed limit, divisors up to a fixed 20000), so no function loop needs a variant.
- **index**: Insertion into the fixed-size result array and the dedupe/sort loops are guarded by count against the array bounds, with for loops over the array's own range for sorting.
- **division**: The modulus in the trial division uses a divisor from a for loop range starting at 2, so it is never zero.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 8 sorted distinct Fortunate numbers one per line.

Assessed on 2026-10-15 against page revision 413989 of the [task](https://rosettacode.org/wiki/Fortunate_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
