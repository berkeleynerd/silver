# Flatten a list

**Candidate: proofs plausibly discharge automatically.** Replacing pointer-based nodes with a bounded token array makes flattening a single for loop over the array's own range, so all checks follow from types, the for-loop index and capacity guards before each append. The only care needed is guarding the loop-carried counters and the text buffer position, which is why this is plausible rather than likely.

Position 1174 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

The nested list is stored as a fixed-capacity array of token records (kind Open, Close or Value, plus an Integer value) in depth-first order, embedded as an aggregate matching the example. One for loop over the token array copies only Value tokens into a bounded integer array with a count guard, and a small procedure renders either the nested or flat form into a fixed-size String buffer using Image with length guards before printing with Put_Line. About 90 lines.

## Proof obligations to watch

- **index**: The output count and text-buffer position are loop-carried, so each append is preceded by an explicit capacity guard that rejects overflow with a visible outcome, as no invariant can be written.
- **range**: Count and position variables are declared with a bounded subtype and incremented only after a guard against the maximum, so the increment check follows from the guard.
- **length**: Building the output line in a fixed-size buffer needs each Image conversion and separator copy to be guarded by remaining capacity before slice assignment.

## Language surface recorded by this assessment

Integers, ranged subtypes, enumerations, arrays, records, for loops, procedures, string building and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the nested list and the flattened list as text lines.

Assessed on 2026-10-15 against page revision 415482 of the [task](https://rosettacode.org/wiki/Flatten_a_list) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
