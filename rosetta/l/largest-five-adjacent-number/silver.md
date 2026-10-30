# Largest five adjacent number

**Candidate: proofs likely to discharge automatically.** Every check follows from ranged subtypes, constant loop bounds over a fixed 1000-character string and a constant-modulus generator, with no loop-carried value needing an invariant. Comparing digit strings lexicographically avoids loop-carried numeric accumulation entirely.

Position 1470 in the [progression](../../progression.md#stage-28), in stage 28, which adds string ordering.

## Approach

A 1000-character String of digit characters is filled in a for loop from a deterministic linear congruential generator held in a ranged subtype, with each digit taken as the state mod 10 and converted via Character'Val (48 + digit). A second for loop over 1 .. 996 compares each five-character slice against the current largest and smallest 5-character String variables (lexicographic order equals numeric order for equal-length digit strings) and copies the slice when it is better. The two results are printed with Put_Line, which preserves leading zeros. About 35 lines.

## Proof obligations to watch

- **overflow**: The generator state is a ranged subtype updated by a small multiply and a mod by a constant, so the product fits and the result stays in range from types alone.
- **index**: Window slices Line (I .. I + 4) use a for loop over 1 .. 996, so bounds follow from the loop range and the fixed 1000-length string.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, string indexing, string ordering, for loops and unconstrained arrays.

## External effects

- **console output** (allowed): Prints the largest and smallest five-digit windows with Put_Line.

Assessed on 2026-10-15 against page revision 408000 of the [task](https://rosettacode.org/wiki/Largest_five_adjacent_number) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
