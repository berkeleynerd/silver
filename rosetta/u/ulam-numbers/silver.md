# Ulam numbers

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic and array indexing with guards placed immediately before use, in a procedure so no loop variants are needed, but several loop-carried indexes and counters need careful guarding and the nested loops make the proof shape delicate. Larger sample indices (10000, 100000) only raise the fixed capacity, not the proof difficulty.

Position 245 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A procedure keeps an array of the first Max_N Ulam numbers and a Boolean membership array over 1..Limit (about 13000 for n up to 1000); for each candidate from 3 upward it counts, with a for loop over the found numbers, the pairs u_i+u_j=c using the membership array and stops counting at 2. A candidate with exactly one pair is appended; if the requested n is not reached within Limit or Max_N the program prints a visible rejection line instead of a result. Main loops over embedded sample indices and prints each result with Image-based text. About 70 lines.

## Proof obligations to watch

- **index**: Indexes into the Ulam list and the membership array are loop-carried, so each is guarded just before use (count below capacity, candidate minus element within 1..Limit) with an explicit rejection outcome when capacity would be exceeded.
- **overflow**: The representation counter is stopped at 2 by a guard and candidates are bounded by a declared Limit subtype, so additions stay inside Integer ranges.
- **termination**: The generator is a procedure (no termination check) and its candidate loop is a for loop over 3..Limit with a flag for completion, so no variant is required.
- **range**: Candidate values and list contents are held in a ranged subtype, and subtraction results are tested to lie in that range before conversion or indexing.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the Ulam numbers for the sample indices (10, 100, 1000) as text lines.

Assessed on 2026-10-15 against page revision 408914 of the [task](https://rosettacode.org/wiki/Ulam_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
