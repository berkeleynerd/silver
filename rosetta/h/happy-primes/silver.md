# Happy primes

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged subtypes, for loops and guards placed before the arithmetic, and the stretch ratios beyond 1/8 are optional and omitted, so only careful shaping of loop-carried counters and the digit-sum is required.

Position 392 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Embed the search bounds as ranged subtypes (values up to 20000), with Is_Prime as a for-loop trial-division function and Is_Happy as a function iterating a digit-square-sum step a fixed 40 times until reaching 1 or 4 (the only unhappy cycle's entry). A main for loop over n counts happy numbers and happy primes, prints the first 50 happy primes ten per row with Put and Integer'Image, and for each k from 3 to 8 prints the first index and value where hpc * k <= hnc using integer arithmetic. Counters are guarded before increment so no overflow check relies on an invariant. About 90 lines.

## Proof obligations to watch

- **overflow**: The happy-number and prime counters are loop-carried, so they are declared with ranged subtypes and guarded before each increment (the search is bounded to values up to 20000).
- **overflow**: The digit-square sum is loop-carried, so it is held in a ranged subtype whose bound (at most 5 digits times 81) is enforced by extracting a fixed number of digits from a value constrained to 0..99999.
- **termination**: Happiness is decided in a function using only for loops (fixed 5 digit steps inside a fixed 40 step iteration that stops once the value reaches 1 or 4), so no variant is needed.
- **overflow**: The primality trial division in a for loop over divisors 2..141 guards d*d <= n before the divide, keeping the nonlinear product within range.
- **other**: The ratio test uses the integer comparison hpc * k <= hnc rather than floating point, bounded by the ranged counters, which keeps it linear and exact.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, functions, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the 50 happy primes and the index/value table for fractions 1/3 through 1/8.

Assessed on 2026-10-15 against page revision 415207 of the [task](https://rosettacode.org/wiki/Happy_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
