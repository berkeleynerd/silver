# Countdown

**Candidate: proofs plausibly discharge automatically.** Everything is bounded by six numbers and values below 10**9, so overflow, index and division checks follow from subtypes and local guards, but the explicit-stack search with many loop-carried indices needs careful program shape. Nothing requires an annotation, and the unbounded-recursion and heap problems are avoided.

Position 745 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed three example games (six numbers and a target each, plus one from a deterministic LCG), and run a brute-force search over pairs of the remaining values with +, -, *, / using an explicit fixed-capacity stack of states (value arrays of up to six entries, current pair and operation indices) in a while loop inside a procedure. Each step records the operation in a bounded step array; when a result equals the target the steps are printed using 'Image text, otherwise a no-solution line is printed. About 170 lines.

## Proof obligations to watch

- **overflow**: Stored values are a ranged subtype capped at 10**9 and products are computed in a 64-bit type so the multiply cannot overflow, then a visible guard checks the result against the cap before storing it.
- **index**: The iterative depth-first search keeps stack depth, pair indices and value counts in ranged subtypes with guards just before each array access, since loop-carried indices have only their type range after the first iteration.
- **termination**: The search is a while loop inside a procedure, which gets no termination check, so no variant is needed; recursion is avoided by using an explicit bounded stack of states.
- **division**: Division is attempted only after guards that the divisor is nonzero and the remainder is zero, and subtraction only when the result stays positive.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, procedures, records, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each puzzle's numbers, target and the found calculation steps, or a no-solution message.

Assessed on 2026-10-15 against page revision 414135 of the [task](https://rosettacode.org/wiki/Countdown) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
