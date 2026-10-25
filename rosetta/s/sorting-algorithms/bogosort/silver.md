# Sorting algorithms/Bogosort

**Candidate: proofs likely to discharge automatically.** Every check follows from the ranged subtypes and the fixed array bounds, and the only loop in a function is a for loop, while the unbounded retry loop is a procedure so it needs no variant. Whether the generator ever reaches a sorted order is not a proof obligation, since procedures get no termination check.

Position 322 in the [progression](../../../progression.md#stage-8), in stage 8.

## Approach

The list is a constant-bounded array of four Integers initialised from an aggregate, with a small linear-congruential generator state in a ranged subtype. A Sorted function loops with a for loop over 1..3 comparing neighbours, and a Shuffle procedure does a Knuth-style swap for each index using a generator-derived index in a 1..4 subtype. The main procedure runs while not Sorted loop Shuffle and then prints the elements with Put and Integer'Image. About 45 lines.

## Proof obligations to watch

- **overflow**: The generator state is a subtype 0..65536 updated as (state * 75 + 74) mod 65537, so the product is bounded by the type and the result stays in range.
- **index**: The shuffle index is computed as state mod 4 + 1 and held in a 1..4 subtype, so every array access is within bounds by type.
- **termination**: The unbounded while loop sits in a procedure so no termination check is generated, and a bound on shuffles would alter the required behavior, so the program keeps it.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, 'Image of scalars, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The sorted list is printed with Put and Put_Line.

Assessed on 2026-10-15 against page revision 414490 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Bogosort) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
