# Display a linear combination

**Candidate: proofs plausibly discharge automatically.** All checks follow from small declared coefficient and position ranges plus explicit capacity guards on the loop-carried buffer index, with only for loops and no recursion, but the string-building shape needs care to discharge without invariants.

Position 1098 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

The ten example scalar lists are embedded as constant arrays of a ranged Coefficient subtype (for example -999..999) with positions 1..4, and a procedure walks each list with a for loop appending terms to a fixed String buffer tracked by a Last index. Each term appends the sign or separator, an optional magnitude and "*" when abs is not 1, then "e(" and the position, using a small digit-conversion helper written with division and mod; an empty result prints "0". Every append is guarded against buffer capacity with a visible failure outcome, and the result slice Buffer(1..Last) is printed with Put_Line. About 110 lines.

## Proof obligations to watch

- **index**: The output buffer's write position is a loop-carried value, so every append is preceded by an explicit capacity guard that rejects with a visible message on overflow, and the buffer is sized above the worst case for the embedded data.
- **length**: Slice and concatenation lengths depend on the computed Last position, which is discharged by the same guards and the Natural subtype range of Last.
- **overflow**: Negating or taking abs of a coefficient is safe because the coefficient type is a small declared range that excludes Integer'First.
- **range**: Digit extraction by repeated division of a ranged coefficient needs the digit count bounded, which the small coefficient range and a fixed digit loop provide.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, unconstrained arrays, string indexing, string building, 'Image of scalars, for loops, procedures and functions.

## External effects

- **console output** (allowed): Each of the ten formatted combinations is printed with Put_Line.

Assessed on 2026-10-15 against page revision 415402 of the [task](https://rosettacode.org/wiki/Display_a_linear_combination) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
