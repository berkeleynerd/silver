# CalmoSoft primes

**Candidate: proofs likely to discharge automatically.** Every bound follows from the fixed p(n) < 100 limit, with sums at most 1060 and a for-loop-only trial division, so checks follow from subtypes and guards placed just before the arithmetic.

Position 357 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Fill a constant-size array with the 25 primes below 100 using a trial-division Is_Prime function built on a for loop (no exit statements), then build a prefix-sum array with guarded additions. Two nested for loops over head and tail indexes test each window's sum with Is_Prime, keeping the longest prime-sum window, and a procedure prints the primes, the sum and the length through scalar image text. The p(n) less than fifty million stretch is omitted as optional. About 95 lines.

## Proof obligations to watch

- **overflow**: Prefix sums and window sums are loop-carried, so each is held in a ranged subtype (0 .. 1060, the sum of all primes below 100) and every addition or subtraction is computed in Integer and guarded before narrowing, with out-of-range falling to a visible Reject.
- **index**: Window start and end indexes come from for loops over the prime array's own range, and the prefix-sum lookup before the first prime is guarded by a Tail = 1 test rather than relying on an invariant.
- **length**: The output text is assembled in a fixed-size buffer sized for 25 primes with up to 3 digits each plus separators, and each append is guarded by remaining capacity.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, functions, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The program prints the longest sequence, its sum and its length to standard output.

Assessed on 2026-10-15 against page revision 394517 of the [task](https://rosettacode.org/wiki/CalmoSoft_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
