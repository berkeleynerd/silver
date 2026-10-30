# Lychrel numbers

**Candidate: proofs plausibly discharge automatically.** The task needs only bounded big-digit arithmetic and for loops in procedures, whose checks follow from ranged types and explicit capacity guards, but the loop-carried digit length and the nested trajectory comparison require careful guard placement.

Position 736 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Represent each number as a fixed 512-digit little-endian array of 0..9 digits plus a length, with procedures for reverse-add, palindrome test and equality. For each n in 1..10000, a for loop of up to 500 iterations records the trajectory and stops at a palindrome; non-palindromic ones are compared against stored seed trajectories (a small 2D table of seeds by 500 steps), counted as related or added as a new seed, with a guard on table capacity. Results are printed with Put, Put_Line and integer image conversion. About 170 lines.

## Proof obligations to watch

- **index**: Digit-array indexes derived from the loop-carried digit length are guarded by an explicit length less than capacity test before each carry append, rejecting otherwise, since only an invariant would show the 5+500 digit bound.
- **overflow**: Per-digit sums are 0..19 in a small ranged subtype and counters are bounded by for-loop ranges, so these discharge from types.
- **index**: Seed-table insertion needs a guard that the seed count is below the fixed table capacity, with a visible rejection otherwise.
- **termination**: All loops live in procedures, with the 500-iteration search as a for loop, so no variant is needed.
- **initialization**: Large digit arrays and the seed trajectory table must be fully initialized by aggregates or loops, which flow analysis handles but needs careful shape.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, records, for loops, while loops, procedures, functions, 'Image of scalars, string building, Put without a newline and characters.

## External effects

- **console output** (allowed): Prints the seed count, the seed numbers, the related count and the Lychrel palindromes.

Assessed on 2026-10-15 against page revision 414003 of the [task](https://rosettacode.org/wiki/Lychrel_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
