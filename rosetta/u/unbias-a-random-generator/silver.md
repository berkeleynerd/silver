# Unbias a random generator

**Candidate: proofs plausibly discharge automatically.** Every check follows from modular wraparound, a ranged N and guarded counter increments, and the unbounded retry loop needs no variant because it lives in a procedure; it is plausible rather than likely only because the loop-carried counters need explicit guards.

Position 1300 in the [progression](../../progression.md#stage-22), in stage 22.

## Approach

A modular 32-bit LCG state, passed in out, drives a procedure Rand_N that returns 1 when the scaled state mod N is zero (N in a subtype 3 .. 6), and a procedure Unbiased that draws pairs in a while loop until they differ and returns the first. Main runs a for loop over N in 3 .. 6 and an inner for loop over a fixed sample count, increments guarded Natural counters of ones for both generators, and prints the counts with 'Image. About 60 lines.

## Proof obligations to watch

- **overflow**: The count accumulators are loop-carried, so each increment needs a guard such as Count < Natural'Last; the guard's else branch can never run with 10_000 samples, so required behavior is unchanged.
- **termination**: The Von Neumann retry loop is a while loop with no variant, so it must sit in a procedure (Unbiased with an in out generator state and an out bit), where GNATprove performs no termination check.
- **range**: Converting the modular LCG state to a bit uses mod N with N in a declared subtype 3 .. 6, so the result and the zero-divisor check follow from the types.

## Language surface recorded by this assessment

Integers, integer division, modular types, ranged subtypes, for loops, while loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): For each N from 3 to 6 the program prints the counts of ones and zeros from randN and from the unbiased generator.

Assessed on 2026-10-15 against page revision 413954 of the [task](https://rosettacode.org/wiki/Unbias_a_random_generator) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
