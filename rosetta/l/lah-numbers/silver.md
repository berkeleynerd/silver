# Lah numbers

**Candidate: proofs plausibly discharge automatically.** Every Lah number up to L(12,12) is at most about 4.4e9, so a 64-bit ranged array with explicit guards proves overflow and index freedom without annotations, though the loop-carried table entries make it depend on careful guard placement.

Position 679 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Use a 13x13 array of a 64-bit range subtype, fill it with the recurrence L(n,k) = (n-1+k)*L(n-1,k) + L(n-1,k-1) from L(0,0) = 1 in nested for loops, and print each row with column values converted to text and joined in a bounded buffer. Before each update, guard that the operands are under a documented 2**40 limit and otherwise reject through a visible outcome. The n = 100 maximum, which needs large integers, is left out as the task makes it conditional on large-integer support. About 55 lines.

## Proof obligations to watch

- **overflow**: Each table entry is computed from loop-carried array values, so a guard that rejects any entry above 2**40 is placed before the multiply-add, which then fits in 64 bits for multipliers of at most 23.
- **range**: Storing the sum into a bounded Lah_Value subtype needs that same visible-reject guard because no invariant can carry the bound across iterations.
- **index**: Row and column indexes come from for loops over the array's own ranges, with n-1 and k-1 reads guarded by explicit tests for n and k of at least 1.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the triangle of unsigned Lah numbers up to L(12, 12) to standard output.

Assessed on 2026-10-15 against page revision 412878 of the [task](https://rosettacode.org/wiki/Lah_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
