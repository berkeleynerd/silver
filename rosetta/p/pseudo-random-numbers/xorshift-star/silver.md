# Pseudo-random numbers/Xorshift star

**Candidate: proofs likely to discharge automatically.** Everything reduces to modular 64-bit arithmetic and a bounded for loop with a small guarded counter array, so all checks follow from types and literal bounds without annotations. The task's float step is replaced by an exactly equivalent integer computation, and the Ada solution's Unseeded_Error exception is not needed because the seeds are fixed nonzero constants.

Position 1262 in the [progression](../../../progression.md#stage-21), in stage 21.

## Approach

Use a modular Unsigned_64 state, with the xorshift steps written as xor with division and multiplication by literal powers of two (wraparound is defined for modular types), and a procedure Next (State in out, Result out Unsigned_32) that multiplies by the constant and divides by 2**32. Instead of floating point, compute the bucket as (Unsigned_64 (R) * 5) / 2**32 using exact integer arithmetic, which equals floor(next_float * 5), and count into a 5-element array in a for loop of 100_000 iterations. Print the results with Unsigned_32'Image and Put_Line, using fixed nonzero seeds so the zero-state case cannot occur. About 50 lines.

## Proof obligations to watch

- **index**: The bucket index is (Unsigned_64 (R) * 5) / 4294967296 with R an Unsigned_32, so it lies in 0..4, which the provers should establish from the type bounds, and a guard before indexing makes it routine.
- **overflow**: The 100_000 increments of a bucket count are loop-carried, so each increment is guarded by a comparison against a literal bound (or uses a counter type whose range exceeds the iteration count) so no invariant is needed.

## Language surface recorded by this assessment

Modular types, integers, integer division, ranged subtypes, arrays, for loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the five generated integers and the five bucket counts with Put_Line.

Assessed on 2026-10-15 against page revision 413866 of the [task](https://rosettacode.org/wiki/Pseudo-random_numbers/Xorshift_star) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
