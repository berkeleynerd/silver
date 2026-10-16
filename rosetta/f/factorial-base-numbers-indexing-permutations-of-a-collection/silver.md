# Factorial base numbers indexing permutations of a collection

**Candidate: proofs plausibly discharge automatically.** Every index and arithmetic check is bounded by ranged subtypes, a validity guard before the rotation, and literal loop bounds, so nothing needs an annotation, but the odometer's loop-carried digits and the 40-million-iteration count need careful guard placement.

Position 578 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Permutations are Natural arrays of fixed capacity 52 with a length n, and factorial base numbers are embedded constant arrays of digits; a validity check guards each rotate step, which is a reverse for loop shifting elements then placing the saved element at position m+1. An odometer procedure with carry guards produces the 24 table rows and counts all 11-place numbers for the 11! comparison without storing them, and the shoe is a 52-character rank string and suit string indexed by mod and / 13 on each card value, printed with Put and Put_Line (T for 10, letters for suits, plus one self-chosen 51-digit number). About 170 lines.

## Proof obligations to watch

- **index**: The rotation touches positions m+1 through m+g+1, so a validity guard (digit g at place m must satisfy g <= n-1-m, otherwise print a rejection line) just before the rotate keeps every index in 1..n; the embedded numbers satisfy it.
- **overflow**: The count of 11! = 39916800 permutations, the factorial product and the odometer carry all stay far below Integer'Last because the digit and counter types are ranged and the loop bound is a literal.
- **termination**: The odometer enumeration uses a while loop inside a procedure, which gets no termination check, with the counter stopping when the carry runs off the most significant place.
- **range**: Loop-carried digit arrays in the odometer lose their invariants after the first iteration, so each digit is a ranged subtype and an increment is guarded by comparing the digit against its radix limit before adding one.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, for loops, while loops, procedures, functions, string building, string indexing, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the 24-row digits-to-permutation table, the permutation count compared with 11!, and the shuffled shoe for each 51-digit number.

Assessed on 2026-10-15 against page revision 414197 of the [task](https://rosettacode.org/wiki/Factorial_base_numbers_indexing_permutations_of_a_collection) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
