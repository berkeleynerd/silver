# Elementary cellular automaton/Infinite length

**Candidate: proofs plausibly discharge automatically.** Everything uses bounded arrays and constant-count for loops, so range and index checks follow from types and static bounds, but the loop-carried length counter and offset arithmetic require careful guards, hence plausible. The task's unlimited cell count is satisfied by a documented fixed capacity sized for the output.

Position 458 in the [progression](../../../progression.md#stage-9), in stage 9.

## Approach

The state is a fixed-capacity Boolean array of cells with a length counter and the two outer background values (left and right infinite fill), starting from the single cell 1 and evolving rules 90 and 30 for a constant number of generations. Each generation, a procedure extends the array by two cells per side filled with the negation of the edge cell, applies the rule bits via a for loop over a 3-bit neighbourhood index, and prints the cells as text art with '.' and '#'. All widths are constants so loop bounds and indexes are statically bounded. About 70 lines.

## Proof obligations to watch

- **index**: Cell indexing during growth and neighbor lookup is guarded by for-loops over the array's own range plus explicit width checks before each step, so bounds follow from loop ranges.
- **overflow**: The support width grows by a fixed amount per generation, so a constant generation count (e.g. 25) with a fixed-capacity array of 2*25+3 cells keeps every index and width bounded by types.
- **other**: Unbounded memory cannot be modeled, so the program fixes a documented capacity and generation count, which the Oracle permits as an explicit resource limit.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, for loops, procedures, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each generation as a line of text art.

Assessed on 2026-10-15 against page revision 412101 of the [task](https://rosettacode.org/wiki/Elementary_cellular_automaton/Infinite_length) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
