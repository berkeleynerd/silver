# Bin given limits

**Candidate: proofs likely to discharge automatically.** Every check follows from array ranges, bounded subtypes and guards just before the operation, and all loops are for loops in procedures, so nothing needs an annotation. The only care is the guarded counter increment and the bounded text formatting.

Position 982 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

The two limit lists and two data lists are embedded as constant Integer arrays, and a procedure first validates that the limits are strictly ascending (rejecting otherwise), then loops over the data, scanning the limits in a reverse for loop with exit to pick a bin and incrementing a bounded-range counter array guarded against its maximum. A print procedure walks the bins with a for loop, formats each limit and count with padding into a bounded string buffer, and emits the line with Put_Line (or Put for the segments); the whole thing is plain iteration with no recursion or heap. About 130 lines.

## Proof obligations to watch

- **overflow**: The per-bin counter is loop-carried and only its type is known after the first iteration, so each increment is guarded by a test against the counter subtype's maximum, with overflow giving a visible rejection.
- **length**: Padded output lines are assembled in a fixed-size buffer whose length is bounded by the digit counts of the Integer-range limits and counts, so each append is guarded against the buffer capacity.
- **index**: The bin index is computed in a reverse for loop over the limits' own range with a bin-index subtype one larger, so each count access is within bounds from types alone.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, unconstrained arrays, for loops, procedures, functions, Boolean objects, 'Image of scalars, string building, string indexing and Put without a newline.

## External effects

- **console output** (allowed): Prints the two bin tables line by line to standard output.

Assessed on 2026-10-15 against page revision 413655 of the [task](https://rosettacode.org/wiki/Bin_given_limits) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
