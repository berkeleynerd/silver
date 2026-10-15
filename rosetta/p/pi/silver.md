# Pi

**Candidate: proofs plausibly discharge automatically.** Iterative fixed-array spigot arithmetic is bounded by declared ranges and local guards with no recursion or heap, so it plausibly proves, but the carried carry and nine-holding logic need careful guard placement and the task's run-forever requirement becomes a documented digit limit.

Position 467 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

The program uses the Rabinowitz-Wagon spigot over a fixed-capacity array of ranged integers sized about 10*N/3 for a documented digit limit N (say 250), with an outer for loop over digits and an inner reverse for loop doing the carry and mod/div step. Predigit and held-nines counters are ranged integers, digits are emitted with Put via Character'Val, and every store into a ranged variable is preceded by an explicit guard that rejects out-of-range values. About 90 lines.

## Proof obligations to watch

- **overflow**: The carry and the per-cell products are loop-carried, so they are held in subtypes whose ranges make 10*cell+carry fit in 64 bits and a guard before each store rejects any value outside the range.
- **range**: Each remainder and quotient stored into a cell or digit subtype needs a guard just before the assignment because no invariant can carry the bound across iterations.
- **index**: All array accesses use for-loop indexes over the array's own range, so they discharge without help.
- **termination**: The held-back run of nines is handled in a procedure with a counted for loop, so no loop variant is needed.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The program prints the digits of pi to standard output.

Assessed on 2026-10-15 against page revision 406413 of the [task](https://rosettacode.org/wiki/Pi) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
