# Goldbach's comet

**Candidate: proofs plausibly discharge automatically.** All checks come from ranged subtypes, a static array bound and loop-condition guards, but the loop-carried count and sieve step need carefully shaped, guarded code, so discharge is plausible rather than routine.

Position 255 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A fixed-size Boolean sieve of Eratosthenes up to 1,000,000 is built in a procedure (for loop over i up to 1000, guarded while loop over multiples), then a procedure counts G(E) by looping i from 2 to E/2 and testing both i and E-i in the sieve. The first 100 even values 4..202 are printed in rows of ten using Integer'Image padded by guarded string building, followed by G(1000000); the stretch chart is omitted as optional. About 80 lines.

## Proof obligations to watch

- **overflow**: The pair-count accumulator is loop-carried, so it needs a ranged subtype bounded by 500000 and a guard before each increment to discharge.
- **index**: The sieve's multiple-stepping while loop is guarded by j <= Limit before every array access and increment, so the index and addition checks follow from the loop condition.
- **termination**: The while loop is placed inside a procedure, which gets no termination check, and all other loops are for loops.
- **stack**: A one-million-element Boolean sieve is a fixed-size array that must fit in stack memory, which is an environmental premise outside the proof.
- **range**: Computing n - i for each i from 2 to 500000 with n fixed at 1000000 stays within the sieve's index range by static bounds.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 10x10 table of G values and the value of G(1000000) to standard output.

Assessed on 2026-10-15 against page revision 414952 of the [task](https://rosettacode.org/wiki/Goldbach's_comet) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
