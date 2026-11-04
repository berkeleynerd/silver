# Nice primes

**Candidate: proofs likely to discharge automatically.** Every value is bounded by small declared ranges and all loops are for loops with static bounds, so range and overflow checks follow from types and no termination annotation is needed.

Position 336 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Declare subtype Candidate is Integer range 500 .. 1000 and write an Is_Prime function using a for loop from 2 to 31 (guarding d*d <= n by exit-free if), a Digit_Sum function using a fixed 4-iteration for loop with n mod 10 and n / 10, and a Digital_Root function that applies Digit_Sum a fixed 3 times (enough for values below 1000). The main procedure loops n over 501 .. 999 (strict bounds), counts matches in a bounded counter, and builds each output line in a bounded String buffer with 'Image before Put_Line, then prints the count. About 55 lines.

## Proof obligations to watch

- **termination**: The digital-root loop and trial division are written as for loops (digit sum via a fixed 4-iteration for loop over n/10 steps), so no variant is needed and no while loop sits in a function.
- **overflow**: All values are in subtype 0..1000 or digit sums at most 27, and the match counter is a subtype bounded by 500, so every addition is bounded by types.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, functions, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the nice primes between 500 and 1000 and their count with Put_Line.

Assessed on 2026-10-15 against page revision 408826 of the [task](https://rosettacode.org/wiki/Nice_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
