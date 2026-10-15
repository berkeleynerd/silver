# Extreme primes

**Candidate: proofs plausibly discharge automatically.** Everything is plain integer arithmetic with types and cap guards bounding the loop-carried sum and divisors, and the loops can be shaped as for loops in functions or while loops in procedures, so no annotation is needed. The main burden is careful range subtypes for the accumulators and number-to-text output.

Position 822 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Values are integers in a subtype capped at 10**12; Is_Prime is a function using a for loop over divisors with exit when D*D exceeds N. A Main procedure loops, finding each next prime with a bounded for-loop search, adding it to the guarded sum, testing the sum for primality, counting extreme primes, and printing rows via Put_Line with 'Image conversions for counts 1 to 30 and 1000, 2000, 3000, 4000 and 5000 until 5000 is reached. About 95 lines.

## Proof obligations to watch

- **overflow**: The running sum and candidate primes are loop-carried, so they are declared in a subtype capped at 10**12 and the sum is guarded before each addition, with a visible stop if the cap is reached.
- **overflow**: D*D in the trial-division test is safe because D is a for-loop index in a range capped at 1_000_000, so the square is at most 10**12.
- **termination**: Primality and next-prime searches use for loops with exit inside functions so no variant is needed, and the unbounded main search is a while loop in a procedure that gets no termination check.
- **range**: Next-prime search is a bounded for loop and, if it finds nothing within the window, the program prints a specified failure message instead of continuing.
- **other**: Trial division over about 100k sums up to 8e10 is slow but only affects runtime, not proof, and the 10,000th stretch extra is omitted as optional.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, functions, procedures, case statements, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 30 extreme primes and the 1000th to 5000th lines as text.

Assessed on 2026-10-15 against page revision 397483 of the [task](https://rosettacode.org/wiki/Extreme_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
