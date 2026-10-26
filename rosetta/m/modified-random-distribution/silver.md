# Modified random distribution

**Candidate: proofs plausibly discharge automatically.** Everything reduces to bounded integer arithmetic, a range-typed LCG, and a for-loop-indexed histogram, with only the counter increments and the LCG update needing careful typing or guards, and the rejection loop living in a procedure so no variant is needed.

Position 383 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

The program uses a deterministic 16-bit linear congruential generator over a range-typed state, with uniform values scaled to integers 0..1023 and an integer V-shaped modifier, and a procedure with a while loop does the rejection sampling (accept when random2 < modifier(random1)). It draws 20,000 samples, increments a 21-element array of bounded counters indexed by value*21/1024, then prints each bin's label and a row of asterisks (count divided by a divisor) using integer image and Put. All indexes and counters come from range-typed subtypes with guards before increments. About 75 lines.

## Proof obligations to watch

- **overflow**: The LCG state is a range-typed integer updated as (state*a+c) mod m with small constants, so the product fits in Integer and the mod result stays in the declared range without an invariant.
- **overflow**: Bin counters are incremented in a loop with no invariant, so each increment is guarded by a count-below-limit test that never triggers with 10,000 to 20,000 draws, or the counter type is wide enough to hold the draw count.
- **index**: The bin index is computed as value*Bins/Scale from a value typed 0..Scale-1 and converted to a ranged subtype, which the prover discharges from the declared ranges.
- **termination**: The rejection loop is a while loop inside a procedure, which gets no termination check, so no variant is needed.
- **floating point**: Using scaled integers (0..1023 with the V modifier as integer arithmetic) avoids floating point entirely, keeping faithful distribution shape.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The histogram lines are written to standard output.

Assessed on 2026-10-15 against page revision 413790 of the [task](https://rosettacode.org/wiki/Modified_random_distribution) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
