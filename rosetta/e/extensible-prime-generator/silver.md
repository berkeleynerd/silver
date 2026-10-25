# Extensible prime generator

**Candidate: proofs likely to discharge automatically.** Every check follows from declared subtypes, the array's static capacity and simple guards just before each increment, and the unbounded search runs in a procedure, so it needs no annotation. The required results stay far below the documented limits.

Position 209 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Main keeps a fixed-capacity array of found primes and a nested Next_Prime procedure that advances an open-ended odd candidate counter in a while loop, testing it by trial division over the stored primes until Candidate / P < P, and appends each new prime when capacity allows. A guard stops with a visible limit message if the candidate reaches its documented maximum, or if the array is full and the largest stored prime is too small to certify the candidate. Main calls Next_Prime in for loops and exit-when loops to print the four required results, using 'Image and Put. About 80 lines.

## Proof obligations to watch

- **overflow**: The open-ended candidate counter and the range-count accumulator are loop-carried, so each increment is preceded by a guard against a documented maximum that leads to a visible 'limit reached' message and stop.
- **index**: The stored-prime count has a subtype of 0 .. Capacity and is incremented only after a Count < Capacity guard, so appending and the trial-division for loop over 1 .. Count stay in bounds.
- **division**: The array elements have a positive subtype, and an aggregate initializes them to 2, so Candidate mod P and Candidate / P (used in place of P * P to avoid nonlinear overflow) cannot divide by zero.
- **termination**: The open-ended search for the next prime is a while loop inside a procedure, which gets no termination check, so it needs no variant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, Boolean objects, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The program prints the first twenty primes, the primes from 100 to 150, the count of primes from 7,700 to 8,000 and the 10,000th prime.

Assessed on 2026-10-15 against page revision 412781 of the [task](https://rosettacode.org/wiki/Extensible_prime_generator) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
