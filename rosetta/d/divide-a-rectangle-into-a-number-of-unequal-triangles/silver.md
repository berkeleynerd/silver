# Divide a rectangle into a number of unequal triangles

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic in for/while loops inside procedures with explicit guards, so no annotation is needed, but the loop-carried LCG state, running offsets and string buffer building require careful guard placement.

Position 624 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Embed integer rectangle dimensions and triangle counts (for example 20x10 with 4 and 30x20 with 8); the first triangle uses three rectangle corners, and the remaining ones fan from the opposite top corner over bottom-edge segments whose gaps strictly increase using a deterministic LCG, so base lengths and therefore areas are all distinct. A guard rejects counts below 3 or above capacity, or a cumulative width exceeding the rectangle (printing a specified rejection message), and the triangles are stored in a bounded array of vertex records and printed as text lines. About 110 lines.

## Proof obligations to watch

- **overflow**: The LCG state and the running x position and gap are loop-carried, so they use bounded integer subtypes with a mod reduction and a guard before each addition that rejects when the cumulative width would exceed the rectangle width.
- **index**: Triangle storage is a fixed-capacity array indexed by a for loop over 1..N, with an explicit guard rejecting a requested count outside the capacity.
- **length**: Output lines are built in a fixed-size buffer sized for the maximum coordinate digits, so each append needs a length guard before writing.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, string building, 'Image of scalars, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints each triangle's vertex coordinates as text lines.

Assessed on 2026-10-15 against page revision 414163 of the [task](https://rosettacode.org/wiki/Divide_a_rectangle_into_a_number_of_unequal_triangles) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
