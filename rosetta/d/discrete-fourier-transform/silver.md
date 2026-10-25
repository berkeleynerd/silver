# Discrete Fourier transform

**Candidate: proofs plausibly discharge automatically.** All loops are for loops over static array ranges so indexes and termination are routine, but float accumulation across loop-carried sums and trig functions need bounded float types and admitted contracted math, making discharge depend on careful shape.

Position 1534 in the [progression](../../progression.md#stage-31), in stage 31.

## Approach

Embed the sequence 2 3 5 7 11 in a constant array of a bounded float subtype, with parallel real and imaginary arrays of fixed capacity for the transform results. Nested for loops over the array's own range compute each output term from a library cos and sin of an angle formed from the integer product k*n, then the inverse transform divides by N and zeroes tiny imaginary parts by a visible threshold comparison. Output prints each value as text via a fixed-format float conversion in a procedure. About 110 lines.

## Proof obligations to watch

- **floating point**: Accumulated sums of products and the exp/cos/sin values must be proven finite, so the program uses a bounded float subtype for inputs and an admitted library with range-contracted sine and cosine.
- **overflow**: Float sums over loop-carried accumulators lose their bounds after the first iteration, so each term is clamped by a visible guard that rejects out-of-range input, and the accumulator type is wide enough to hold N times the maximum term.
- **range**: The angle 2*pi*k*n/N needs a bounded integer product k*n with a range-limited N and a division guarded by N being at least 1.
- **division**: The 1/N scaling and the angle division are safe because N is a constant in a positive subtype.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, floating point, arrays, records, functions, procedures, for loops, block statements, floating-point images, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the original sequence, its transform and the recovered sequence.

Assessed on 2026-10-15 against page revision 412076 of the [task](https://rosettacode.org/wiki/Discrete_Fourier_transform) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
