# Iccanobif primes

**Candidate: proofs plausibly discharge automatically.** The required 10 primes need only Fibonacci values below 10^6 and plain 64-bit arithmetic, so every check follows from types and guards placed just before additions and multiplications. The loop-carried accumulators need explicit limit guards but no annotation, and the while loops sit in procedures, so the outlook is plausible.

Position 234 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Main iterates Fibonacci numbers F(1..) in a guarded for loop over a bounded index with two Long_Long_Integer-range variables, and for each value calls a reversal procedure (while loop over digits with a guarded accumulator) and a trial-division procedure returning a Boolean out parameter. Each hit is printed with Put_Line of the integer image and counted until 10 are found; the loop ends at the count, and the guard-limit exit has a visible outcome. The 10 required primes all come from Fibonacci numbers up to F(26), well inside 64 bits, and the stretch (digit counts of 15 more, needing thousands of digits) is treated as optional and omitted. About 70 lines.

## Proof obligations to watch

- **overflow**: The Fibonacci recurrence a+b is loop-carried, so it is guarded by an explicit upper limit on both operands before each addition, with the loop stopping when the limit is hit.
- **overflow**: The digit-reversal accumulator r*10+d is loop-carried and is guarded by checking r against a limit just before the multiplication, which cannot trigger for numbers up to about 10^17.
- **overflow**: Trial division uses the divisor test d <= n / d instead of d*d <= n so no product can overflow.
- **termination**: Primality and reversal loops are while loops, so they live in procedures with out parameters rather than functions to avoid needing a variant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the first 10 iccanobif primes, one per line.

Assessed on 2026-10-15 against page revision 414263 of the [task](https://rosettacode.org/wiki/Iccanobif_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
