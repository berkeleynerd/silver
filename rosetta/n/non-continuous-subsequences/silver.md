# Non-continuous subsequences

**Candidate: proofs likely to discharge automatically.** Subset enumeration by bitmask with Boolean state flags and a bounded output buffer needs only range-typed values and guards just before each use, so every check follows from types and local conditions.

Position 531 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

A procedure Show(N) in 1..5 loops over every subset bitmask up to a bound taken from a small constant, peeling bits with mod 2 and /2 on a loop-carried natural bounded by its subtype. Booleans Started, Gapped and Non_Continuous track the pattern one, then zero, then one, while a bounded String buffer with a guarded position collects the selected digit characters; a non-continuous mask is printed with Put_Line on the used slice, with a blank line between sequences. No recursion, no while loops and no contracts are needed. About 70 lines.

## Proof obligations to watch

- **index**: The output buffer position is a ranged subtype and every write is guarded by a test that the position is below the buffer capacity, so no invariant is needed.
- **range**: The element digit comes from the for-loop index over 1..5 converted with Character'Val of a bounded value, so the conversion check follows from the loop range.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, string indexing, string building, for loops and procedures.

## External effects

- **console output** (allowed): Each non-continuous subsequence is printed as one line of digits for the sequences of 3, 4 and 5 elements.

Assessed on 2026-10-15 against page revision 414358 of the [task](https://rosettacode.org/wiki/Non-continuous_subsequences) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
