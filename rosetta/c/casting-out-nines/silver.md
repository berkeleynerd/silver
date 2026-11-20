# Casting out nines

**Candidate: proofs likely to discharge automatically.** All values are bounded by declared subtypes, the accumulator is reduced each step so no loop invariant is needed, and loops are for loops over fixed ranges, so every check follows from types and simple guards.

Position 350 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Embedded constants set the range 1..100 and bases 10 and 16; function Co9 (value in a bounded subtype, base in 2..16) peels digits with a fixed-count for loop, adding each digit to a running residue kept in 0..Base-2 by conditional subtraction (repeated digit addition, 0 reported as Base-1). A for loop over k prints those k with Co9(k) = Co9(k*k) via Put and Image-style conversion into a bounded buffer, counts them, then prints the count and an integer percentage saving, and a second pass with the mod (Base-1) shortcut for Part 3 compares equal results. About 70 lines.

## Proof obligations to watch

- **overflow**: The digit-sum accumulator is kept in a subtype 0..8 by subtracting 9 whenever it reaches 9, so each addition is bounded by types alone and needs no invariant.
- **overflow**: k*k is computed only for k in a declared range of at most 10000 (and Base in a small declared range), so the square fits in Integer by types.
- **termination**: Digit extraction uses a for loop over a fixed maximum digit count (10 iterations) rather than a while loop, so no variant is needed even if co9 is a function.
- **division**: Division by Base-1 is safe because Base is a subtype declared as 2..16 so Base-1 is at least 1, and the percentage divides by a count that is guarded to be nonzero.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, procedures, functions, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the filtered numbers and the proportion summary lines.

Assessed on 2026-10-15 against page revision 414764 of the [task](https://rosettacode.org/wiki/Casting_out_nines) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
