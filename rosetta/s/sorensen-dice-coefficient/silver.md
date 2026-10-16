# Sorensen–Dice coefficient

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed array bounds, for-loop ranges and guards before counter increments, with integer scaled scores instead of floating point, so no annotation is needed, but the many loop-carried counters demand careful guard placement. The dictionary must be an embedded subset because reading the full task list is peripheral and file input is unnecessary.

Position 952 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

The program embeds a fixed dictionary of Rosetta task names as constant strings in a constant array of fixed-capacity padded strings with lengths, plus the four mangled search terms. A procedure builds case-folded bigrams per word (skipping spaces) into a bounded array with a guarded count, a second procedure computes the multiset intersection using a used-flag array, and scores are scaled integers. For each term a procedure keeps the top five entries by insertion into fixed arrays and prints each score formatted to four decimals using integer division and 'Image. About 170 lines.

## Proof obligations to watch

- **overflow**: Loop-carried bigram counts and intersection counters are guarded against their declared range maximum just before each increment, since no invariant can bound them.
- **index**: Bigram arrays are sized for the longest embedded name and every store is guarded by a count check, while string indexing uses for-loop ranges over the string's own bounds.
- **division**: The score divides by the total bigram count, so a guard handles the zero-total case with a specified score of zero.
- **overflow**: Scores are scaled integers (twice the intersection times 10000 divided by the total) with bounded operands, and ranking compares by integer cross-multiplication, avoiding floating point.
- **termination**: All loops are for loops or live in procedures, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, records, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, functions, Boolean objects, conditional expressions and Put without a newline.

## External effects

- **console output** (allowed): The program prints each search term and its five best matches with scores to standard output.

Assessed on 2026-10-15 against page revision 414482 of the [task](https://rosettacode.org/wiki/Sorensen%E2%80%93Dice_coefficient) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
