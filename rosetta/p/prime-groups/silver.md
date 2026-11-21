# Prime groups

**Candidate: proofs likely to discharge automatically.** All loops are for loops over the string's own index range and the only arithmetic is on bounded character-code differences, so every check follows from types and loop ranges with no annotation needed.

Position 1063 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Each test string is passed to a procedure Solve (S : String; N : Natural range 2..3) that tries index combinations in lexicographic order with nested for loops, using a function Is_Prime (D : Natural) that tests trial division with a for loop up to a constant bound. For each group it checks all pair differences of Character'Pos values, prints the first matching group built by concatenating characters, and otherwise prints "Not found."; the six embedded strings are called for group sizes 3 then 2 with a Found flag and exit-free loops guarded by that flag. About 80 lines.

## Proof obligations to watch

- **overflow**: The difference of two Character'Pos values lies in 0..255 by type, so abs and subtraction cannot overflow.
- **index**: The nested for loops index S(I), S(J), S(K) with bounds derived from S'First and S'Last, so index checks follow from loop ranges, though the I+1 and J+1 loop starts need the first-greater-than-last guard to avoid overflow on S'Last.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, unconstrained arrays, string indexing, string building, for loops, procedures and functions.

## External effects

- **console output** (allowed): Prints one result line per test string for each group size.

Assessed on 2026-10-15 against page revision 407671 of the [task](https://rosettacode.org/wiki/Prime_groups) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
