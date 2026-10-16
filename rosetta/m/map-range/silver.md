# Map range

**Candidate: proofs plausibly discharge automatically.** The program needs only bounded floating-point arithmetic inside a for loop with a guarded nonzero divisor, so no annotation is required, but float reasoning and the Float image formatting make discharge depend on careful range bounds.

Position 1041 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

A generic-free function Map_Range takes a1, a2, b1, b2 and s as bounded Float subtypes, guards a2 /= a1 and s within [a1,a2] (otherwise returning a visible rejection through the caller), and returns b1 + (s - a1)*(b2 - b1)/(a2 - a1). Main loops a for loop over integers 0 to 10, converts the index to Float, maps it from [0,10] to [-1,0], and prints the pair with Put_Line using Float'Image concatenation. About 30 lines.

## Proof obligations to watch

- **floating point**: The mapping t = b1 + (s - a1)*(b2 - b1)/(a2 - a1) is discharged by declaring the operands in bounded Float subtypes (0.0 to 10.0 and -1.0 to 0.0) so no intermediate can overflow or be infinite or NaN, though float provers may need range guards.
- **division**: The divisor a2 - a1 is a nonzero value that must be known to the prover, so the function either takes a ranged subtype that excludes equal endpoints or guards with an explicit a2 /= a1 test that rejects degenerate ranges visibly.
- **range**: Converting the Float result back into the second-range subtype needs a bound on the result; with s inside [a1,a2] and the guard in place the result is within [b1,b2], but the prover must reason about rounding at the boundary, which may need a clamp-free guard on the computed value.
- **length**: Each output line concatenates two Float'Image results with fixed text, so the bounded string buffer must be sized for the maximum image length.

## Language surface beyond today's Silver

Integers, ranged subtypes, floating point, functions, for loops, floating-point images and string building.

## External effects

- **console output** (allowed): Prints each of the eleven source values with its mapped value, one line each.

Assessed on 2026-10-15 against page revision 411622 of the [task](https://rosettacode.org/wiki/Map_range) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
