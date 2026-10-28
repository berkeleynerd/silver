# Sum of first n cubes

**Candidate: proofs likely to discharge automatically.** The product N*(N+1) lies in 0..2450 and quotient in 0..1225. The full declared-range square is at most 1500625, within Integer. Divisor 2 is nonzero and all assignments preserve the object-local range.

Position 20 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main initializes Triangular : Integer range 0 .. 1225 := 0. For N in 0 .. 49 it assigns Triangular := ((N * (N + 1)) / 2) and prints Integer'Image ((Triangular * Triangular)). This prints the task's first 50 sums starting with n=0; no local declaration region, procedure or declared subtype is needed. About 12 lines.

## Language surface recorded by this assessment

Integer range for loops, immutable Integer arithmetic, interval-checked Integer division, bounded mutable Integer objects and Integer image.

## External effects

- **console output** (allowed): Prints the 50 running sums to standard output, one per line.

Initially assessed on 2026-10-15 against page revision 408965 of the [task](https://rosettacode.org/wiki/Sum_of_first_n_cubes) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-division-20261025.md).
