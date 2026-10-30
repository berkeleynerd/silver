# RPG attributes generator

**Candidate: proofs likely to discharge automatically.** The checks reduce to modular wraparound arithmetic, a mod 6 result converted into 1..6, attribute bounds that follow from comparisons made just before each use, and fixed-size sums. The only unbounded loop is in a procedure, so nothing needs an annotation.

Position 1266 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

A linear congruential generator on a mod 2**32 state yields each die as (State / 2**16) mod 6 + 1. Main converts that value into the declared range 1..6, keeps the four dice and six attributes in small constrained arrays, and rolls inside nested for loops. A plain loop with an exit when test rerolls until the straight-line total is at least 75 and at least two attributes are 15 or more, then prints each value and the total with 'Image. About 50 lines.

## Proof obligations to watch

- **range**: Each attribute (sum of four dice minus the lowest) stays in 3..18 because the lowest die comes from straight-line if comparisons, so the prover knows it is at most each die, not from a loop whose result it knows only by type.
- **overflow**: The total and the count of values of 15 or more are computed as straight-line expressions over the six fixed array elements, so no loop-carried accumulator can appear to overflow.
- **termination**: The reroll-until-acceptable loop lives in Main, a procedure, so it gets no termination check, and with a fixed seed the deterministic generator reaches an acceptable roll after a fixed number of tries.

## Language surface recorded by this assessment

Integers, integer division, modular types, ranged subtypes, arrays, for loops, while loops and 'Image of scalars.

## External effects

- **console output** (allowed): The six attribute values and their total are printed with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 414424 of the [task](https://rosettacode.org/wiki/RPG_attributes_generator) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
