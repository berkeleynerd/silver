# Fusc sequence

**Candidate: proofs plausibly discharge automatically.** Every check follows from integer ranges and guards, but the loop-carried accumulators in the bit-based fusc computation and the comma-formatting buffer need careful guards because no invariants are allowed. No recursion, heap or annotation is needed.

Position 398 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Compute fusc(n) iteratively from the bits of n using two accumulators a and b in a procedure (a for loop over 31 bit positions with n halved each step, guarded against exceeding a ceiling), without recursion or a big table. A main loop prints the first 61 values, then scans indices up to a fixed bound (20,000,000 or a smaller documented limit), tracks the maximum digit count in an integer, and prints each new record index and value with commas via a bounded String buffer built from digit extraction with mod and /. About 90 lines.

## Proof obligations to watch

- **overflow**: The bit-wise fusc computation carries two accumulators through a loop with no invariant, so each addition is preceded by a guard against a fixed ceiling on a 64-bit range type, with a visible rejection outcome.
- **termination**: The halving loop is placed in a procedure (no termination check) or written as a for loop over a fixed 31 bit positions, avoiding a variant.
- **length**: Comma-grouped number text is built into a fixed-size bounded buffer whose index arithmetic needs guards just before each store.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 61 fusc numbers and the table of record-length fusc numbers with their indices.

Assessed on 2026-10-15 against page revision 414227 of the [task](https://rosettacode.org/wiki/Fusc_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
