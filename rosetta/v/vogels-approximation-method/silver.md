# Vogel's approximation method

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded by small declared ranges and the loops are for loops over array ranges or a while loop in a procedure, so no annotation is needed. The care needed is in keeping loop-carried indexes in range through initialised defaults and in bounding the running totals.

Position 726 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed the 4x5 cost matrix, supplies and demands as constant arrays of small ranged subtypes, with mutable copies and Boolean done flags for rows and columns. A while loop in the Main procedure computes penalties for active rows and columns using nested for loops, picks the largest penalty (ties to the lowest cost), allocates min(supply, demand) to the cheapest active cell, and accumulates the total. The allocation matrix and the total are printed with Put_Line and bounded string building. About 110 lines.

## Proof obligations to watch

- **overflow**: Costs, quantities and the running total are held in bounded integer subtypes (costs at most 50, quantities at most 70, total at most 70 times 50 times 5), so products and sums fit in Integer.
- **index**: Row and column indexes chosen by the selection loop are loop-carried, so the program initialises them to a valid in-range default and only overwrites them with for-loop indexes over the array ranges, which keeps every access in bounds.
- **termination**: The allocation loop is a while loop inside a procedure, which gets no termination check, and it ends because each pass allocates a positive quantity to a cell that is not done.
- **overflow**: The penalty is the difference of two costs held in an Integer-based subtype, and a sentinel for a missing second minimum is a fixed in-range constant, so the subtraction cannot overflow.
- **other**: A pass that finds no active row or column must leave the loop with a specified outcome; this is a guard on the loop condition, not a change to results, so the 3100 result is unaffected.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the allocation matrix and the total cost of 3100.

Assessed on 2026-10-15 against page revision 414576 of the [task](https://rosettacode.org/wiki/Vogel's_approximation_method) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
