# Eban numbers

**Candidate: proofs plausibly discharge automatically.** Every check is arithmetic on constant-bounded integers inside for loops with no recursion, so only the loop-carried count needs a guard, and no annotation is required.

Position 392 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A pure Is_Eban function splits a value up to 10_000_000 into thousand-groups by constant division and mod, treats a group as eban when it is 0, 2, 4, 6 or in 30..66 with a units digit of 0, 2, 4 or 6, and a procedure runs for loops over the static ranges. Lists are emitted with Put and a separator after each number, counts use a bounded accumulator with a pre-increment guard, and numbers are printed via 'Image. All limits are fixed constants in the source. About 90 lines.

## Proof obligations to watch

- **overflow**: The running count is loop-carried and GNATprove only knows its type after the first iteration, so the program uses a count subtype of 0 .. 10_000_000 with an explicit guard before the increment that reports a visible failure message instead of silently capping.
- **range**: The loop index and the splitting by constant / and mod stay within declared subtypes, so these checks are routine once the for-loop ranges are static subtypes.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, functions, procedures, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the eban lists and the counts as text lines.

Assessed on 2026-10-15 against page revision 414172 of the [task](https://rosettacode.org/wiki/Eban_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
