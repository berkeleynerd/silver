# Entropy/Narcissist

**Candidate: proofs plausibly discharge automatically.** Every integer check follows from range-limited types and an explicit size cap, but the floating-point entropy sum needs Log preconditions and accumulator bounds to be shown through guards alone, which makes discharge depend on careful program shape rather than being routine.

Position 1448 in the [progression](../../../progression.md#stage-27), in stage 27.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.

## Approach

The program takes its own source file name as the first argument, reads it character by character in a procedure with a while loop into a 256-entry count array indexed by Character, rejecting files that are unreadable, empty or above a fixed byte cap. A for loop over the array then sums p times log2 p in a floating-point accumulator, skipping zero counts and guarding the accumulator range before each addition, and the result is printed with a fixed number of decimals through a bounded text buffer. About 70 lines.

## Proof obligations to watch

- **floating point**: Log needs a strictly positive argument and the entropy sum must not overflow, discharged by only taking the logarithm when the count is at least 1 and by a guard that rejects if the running sum leaves a fixed bound before each add.
- **overflow**: Histogram counts are loop-carried and incremented in the read loop, so they are held in a range-limited type and reading stops with a rejection at a fixed maximum file size, giving a visible outcome rather than silent truncation.
- **division**: The division by total length is guarded by rejecting an empty file before the entropy loop.
- **floating point**: Float(V)/Length lies in (0,1] only by invariant reasoning, so the program instead relies on the bounded count type and a clamped term range, which the provers must handle with nonlinear float reasoning.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, for loops, while loops, procedures, functions, floating point, floating-point images, 'Image of scalars, string building, file input, further arguments and Put without a newline.

## External effects

- **arguments** (allowed): The first command-line argument names the program's own source file.
- **files** (allowed): The program reads that source file's bytes to build the character histogram.
- **console output** (allowed): The computed entropy is printed as text.
- **exit status** (allowed): An unreadable, empty or oversized source file is rejected with a non-zero status.

Assessed on 2026-10-15 against page revision 415301 of the [task](https://rosettacode.org/wiki/Entropy/Narcissist) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
