# Pseudo-random numbers/Middle-square method

**Candidate: proofs likely to discharge automatically.** The seed's declared range bounds the square below 10**12, so no overflow or range check needs a loop invariant, and the five-iteration for loop terminates by itself. The only new surface is ranged subtypes, integer arithmetic, a procedure and 'Image output.

Position 122 in the [progression](../../../progression.md#stage-6), in stage 6.

## Approach

Declare a seed subtype 0 .. 999_999 and a procedure Next (Seed : in out Seed_Type) that squares the seed in Long_Long_Integer, divides by 1_000 and takes mod 1_000_000, which equals the middle six digits of the zero-padded 12-digit square. Main starts with seed 675_248 and runs a for loop of five iterations, calling Next and printing the value with Put_Line and 'Image; no recursion, loop-carried facts or guards are needed because the seed type bounds every value. About 25 lines.

## Proof obligations to watch

- **range**: The squared seed is computed in a 64-bit integer type and the mod 1_000_000 result is converted back to the 0..999_999 seed subtype, which solvers discharge from the type bounds alone.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the five generated numbers, one per line, with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 411927 of the [task](https://rosettacode.org/wiki/Pseudo-random_numbers/Middle-square_method) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
