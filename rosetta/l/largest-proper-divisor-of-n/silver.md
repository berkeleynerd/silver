# Largest proper divisor of n

**Candidate: proofs likely to discharge automatically.** The outer quotient lies in 0..50; live inner-loop indexes lie in 1..50, excluding zero and fitting Largest's declared range. Both modulo sites have nonzero divisors. Padding uses an ordinary scalar condition without narrowing a later arithmetic expression.

Position 47 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main initializes Largest : Integer range 1 .. 50 := 1. For each N in 1 .. 100 it resets Largest to 1, then loops D over 1 .. (N / 2), assigning Largest := D whenever (N mod D)=0. Ascending enumeration leaves the largest proper divisor last. Put emits padded Integer images and every tenth N ends a row. The task's a(1)=1 convention handles the empty inner loop. About 25 lines.

## Language surface recorded by this assessment

Integer range for loops, immutable Integer arithmetic, interval-checked Integer division, bounded mutable Integer objects, Integer image and Put without a newline.

## External effects

- **console output** (allowed): Prints the 100 values as ten rows of ten right-aligned numbers.

Initially assessed on 2026-10-15 against page revision 414303 of the [task](https://rosettacode.org/wiki/Largest_proper_divisor_of_n) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-division-20261025.md).
