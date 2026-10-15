# Pseudo-random numbers/Splitmix64

**Candidate: proofs likely to discharge automatically.** Modular Unsigned_64 arithmetic has no overflow checks and the floor(next_float*5) step can be done in exact integer arithmetic, so only the loop-carried count increments and the bucket index need simple guards. No loop invariant, recursion or floating point is required.

Position 1277 in the [progression](../../../progression.md#stage-22), in stage 22.

## Approach

A Main procedure declares Unsigned_64 state and a small Natural count array indexed 0..4, with a procedure Next(State, Result) doing the add, xor, Shift_Right and multiplications with wraparound. It prints five values via Unsigned_64'Image, then runs a for loop of 100000 calls from seed 987654321. The bucket is computed exactly in integer arithmetic as ((hi*5) + ((lo*5)>>32))>>32 with hi and lo the 32-bit halves, instead of floating point, and is guarded before indexing. About 55 lines.

## Proof obligations to watch

- **overflow**: The 100000-iteration bucket increments are loop-carried, so they use a guard before the add (or a modular counter) because only the type range is known after the first iteration.
- **index**: The bucket index is derived by shifts and multiplies, so the program guards it with an explicit test against 4 before indexing and takes a visible Reject-style outcome otherwise.

## Language surface beyond today's Silver

Modular types, integers, ranged subtypes, arrays, for loops, procedures, 'Image of scalars and integer division.

## External effects

- **console output** (allowed): Prints the five integers and the five bucket counts with Put_Line.

Assessed on 2026-10-15 against page revision 413865 of the [task](https://rosettacode.org/wiki/Pseudo-random_numbers/Splitmix64) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
