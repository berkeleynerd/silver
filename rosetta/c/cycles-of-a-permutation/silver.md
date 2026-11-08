# Cycles of a permutation

**Candidate: proofs plausibly discharge automatically.** Everything uses fixed 15-element arrays with indexes drawn from a 1..15 subtype and loops confined to procedures, so checks follow from types and bounded guards without annotations; the main care is loop-carried counters and the lcm arithmetic.

Position 751 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Letters are fixed 15-character String constants and permutations are arrays of a 1..15 subtype, with cycles stored as a 15x15 table plus a per-cycle length array and cycle count. Procedures compute one-line notation by scanning for each letter, invert it, apply it to a string, decompose into cycles with a while loop over an array of visited flags, compose by permuting then re-decomposing, and compute order via gcd/lcm and signature via parity of even-length cycles. The demonstration prints each result with Put and Integer'Image under explicit guards. About 230 lines.

## Proof obligations to watch

- **index**: Position values are held in a subtype 1..15 and character lookups loop over the fixed 15-letter range, so indexing is checked against static bounds.
- **overflow**: The order is an lcm folded over at most 15 cycle lengths in a procedure, bounded by the declared range of the order type (the true maximum is far below it) with a guard before the multiply.
- **termination**: Cycle-following and Euclid gcd loops are while loops, so they live in procedures where no termination check is made, never in functions.
- **index**: The cycle-element counter is a loop-carried value, so it is guarded against the capacity of 15 before each append since no invariant can be written.
- **length**: Output lines are built from bounded buffers with explicit capacity guards before each concatenation.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, 'Image of scalars, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The demonstration prints the cycles, one-line notations, permuted strings, signatures and orders for the seven days.

Assessed on 2026-10-15 against page revision 414144 of the [task](https://rosettacode.org/wiki/Cycles_of_a_permutation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
