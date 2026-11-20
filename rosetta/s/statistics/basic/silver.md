# Statistics/Basic

**Candidate: proofs plausibly discharge automatically.** Streaming mean, variance and histogram over a deterministic integer fixed-point generator needs only integers, arrays, loops and text building, with all checks following from ranged types and a few overflow guards on loop-carried accumulators. It is plausible rather than likely because the accumulators and the nonlinear LCG and variance arithmetic depend on careful range sizing.

Position 415 in the [progression](../../../progression.md#stage-8), in stage 8.

## Approach

A deterministic linear congruential generator over a ranged integer state yields samples as fixed-point integers scaled to 0..1_000_000, and one procedure accumulates count, sum, sum of squares and an 11-bin histogram array in streaming fashion for sizes 100, 1000 and 10000. Mean and standard deviation come from sum and sum-of-squares via the hint formula with integer arithmetic and a bounded integer square root, and are printed as scaled decimals built into a bounded string with 'Image digits. Histogram rows are built with a for loop of X characters and printed with Put_Line, with each accumulator addition guarded against its type maximum. About 110 lines.

## Proof obligations to watch

- **overflow**: Loop-carried sum, sum of squares and bin counters lose their bounds after the first iteration, so each addition is preceded by an explicit guard against the type maximum that rejects with a visible outcome, or sample counts and scaled values are fixed so the 64-bit range clearly suffices.
- **overflow**: The LCG step multiplier times state is nonlinear, so the state is a bounded range type with a modulus small enough that the product fits in 64 bits, which provers handle from the type bounds.
- **index**: The histogram bin index is computed as sample times 10 divided by the scale from a ranged sample value, so the index range follows from the sample type, with a guard on the top edge.
- **division**: Mean and variance divide by the sample size, which is a nonzero constant or ranged subtype of the loop, so the divisor is provably positive.
- **termination**: The integer square root is a bounded for loop or a while loop inside a procedure, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, functions, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints each sample size's mean, standard deviation and an ASCII histogram.

Assessed on 2026-10-15 against page revision 414515 of the [task](https://rosettacode.org/wiki/Statistics/Basic) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
