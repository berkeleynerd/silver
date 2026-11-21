# Random numbers

**Candidate: proofs plausibly discharge automatically.** Everything is bounded by types and array ranges with a deterministic generator and only for loops, so the only non-routine checks are the float accumulator bounds and float output formatting, which need careful shape but no annotation.

Position 964 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

A constant-seeded linear congruential generator keeps its state in a range subtype below 2**31 and is stepped by a procedure with an in out parameter, and a function turns the state into a float in [0,1). A 1000-element Float array is filled by a for loop over its own range, each element being 1.0 + 0.5 * (sum of 12 uniforms minus 6.0), and the program then prints the elements or their mean through Silver_IO. About 45 lines.

## Proof obligations to watch

- **overflow**: The LCG step state*A+C is nonlinear, but the state is a range type below 2**31 and A is below 2**31, so the product stays under 2**62 and fits a 64-bit integer, which the provers can discharge from the type bounds.
- **floating point**: Each uniform is an integer in 0..2**31-1 divided by a positive constant, and 12 of them are summed in a loop whose accumulator is only bounded by its type, so the accumulator needs a bounded float subtype or an unrolled fixed sum, otherwise the overflow check may not discharge.
- **floating point**: A faithful Box-Muller version would need Sqrt, Log and Cos from an admitted library with positivity preconditions, so the program uses the sum-of-12-uniforms approximation (mean 1.0, standard deviation 0.5 after scaling) instead, a variation the task text allows.
- **other**: Formatting floats with 'Image has no verified contract in plain SPARK, so the output may instead print scaled integers or need an admitted float-formatting library operation.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, floating point, floating-point images, 'Image of scalars, arrays, for loops, procedures and functions.

## External effects

- **console output** (allowed): The program prints the generated numbers, or a summary of them, to show the collection was filled.

Assessed on 2026-10-15 against page revision 415353 of the [task](https://rosettacode.org/wiki/Random_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
