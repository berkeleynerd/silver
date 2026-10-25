# Magic squares of odd order

**Candidate: proofs likely to discharge automatically.** Every check is an index or arithmetic bound that follows from subtypes, a small documented maximum N, and guards before each wraparound step, so no annotation is needed. The fill loop only needs the types of its carried positions, which are tight enough because the wrap tests are explicit.

Position 658 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Use a constant-capacity two-dimensional Natural array (e.g. 15x15) and a procedure taking an odd N, which rejects even or out-of-range N and otherwise fills the square by the Siamese method in a for loop over 1..N*N with guarded wraparound of row and column, moving down when the up-right cell is already nonzero. The main program calls it for embedded values such as 3 and 5, printing each row with padded integer images via Put and a line terminator, then the magic number N*(N*N+1)/2. About 70 lines.

## Proof obligations to watch

- **index**: The loop-carried row and column positions are typed as a subtype 0..Max-1 and each step is guarded by an explicit wrap test against N, so every array index check follows from the type.
- **overflow**: N is bounded to an odd value up to a documented maximum such as 15, so N*N and the magic constant N*(N*N+1)/2 stay within Integer without needing a loop invariant.
- **range**: Computing the next position as 'if X >= N-1 then 0 else X+1' keeps the result inside the subtype, and the start column N/2 is within range given N in 3..15.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, for loops, procedures, Put without a newline and 'Image of scalars.

## External effects

- **console output** (allowed): The square rows and the magic number are written to standard output.

Assessed on 2026-10-15 against page revision 414323 of the [task](https://rosettacode.org/wiki/Magic_squares_of_odd_order) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
