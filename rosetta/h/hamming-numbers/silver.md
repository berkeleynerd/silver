# Hamming numbers

**Candidate: proofs plausibly discharge automatically.** Every check follows from subtype ranges and guards placed just before pointer increments and stores, with no recursion or while loops, but the loop-carried pointers and capped values make discharge depend on careful program shape.

Position 102 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Keep a constant-size array of 1691 values of a capped 64-bit integer subtype, initialized to 1, plus three pointer variables and three candidates (2x, 3x, 5x of the pointed values). A for loop from 2 to 1691 picks the minimum candidate, stores it, and advances every pointer whose candidate equals it (handling duplicates), with guards before each index step and before storing; then a for loop prints the first twenty values with Put and 'Image, and Put_Line prints the 1691st. The optional one-millionth number is omitted since it needs big numbers beyond the stated requirement. About 60 lines.

## Proof obligations to watch

- **index**: The three merge pointers are loop-carried and only bounded by their subtype range, so each increment and each Values(I) read needs an explicit guard (pointer below the last slot) with a visible Reject outcome.
- **range**: The selected minimum of the three candidates is stored into a bounded Hamming_Value subtype, so a guard against the bound (with visible rejection) is needed since no invariant can show the values stay below it.
- **overflow**: Multiplying a stored value by 2, 3 or 5 is safe because the element subtype is capped well below 2**60, so the product fits a 64-bit integer from types alone.
- **initialization**: The whole Values array is initialized with an aggregate before the loop so reads at pointer positions are always of initialized data.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops, 'Image of scalars, Put without a newline, procedures and Boolean objects.

## External effects

- **console output** (allowed): Prints the first twenty Hamming numbers and the 1691st to standard output.

Assessed on 2026-10-15 against page revision 414677 of the [task](https://rosettacode.org/wiki/Hamming_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
