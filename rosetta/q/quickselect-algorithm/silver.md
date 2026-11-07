# Quickselect algorithm

**Candidate: proofs plausibly discharge automatically.** Everything uses fixed-size arrays, bounded index subtypes and while loops inside procedures, so no annotation is needed, but the loop-carried indices need guards before each use to discharge without invariants.

Position 234 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Embed the ten values in a constant array of Integer indexed by a 0..9 subtype, and for each rank k copy it into a working array. A procedure runs a while loop with lo and hi bounds, partitions with a Lomuto scheme (last element as the deterministic pivot, for loop over the range, guarded store index) in descending order, then narrows toward k. It prints each result with Integer'Image through Put, so the ten largest appear in order. About 70 lines.

## Proof obligations to watch

- **index**: Loop-carried partition store index and the narrowing bounds lo and hi are known only by type, so each increment, decrement and array access is preceded by an explicit guard against the Index bounds.
- **range**: Updates such as lo := p + 1 and hi := p - 1 are guarded by p < Index'Last and p > Index'First, with the empty-range cases handled as an exit from the selection loop.
- **termination**: The selection and partition loops sit in procedures, which get no termination check, so no variant is needed.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the ten selected values in order to standard output.

Assessed on 2026-10-15 against page revision 411875 of the [task](https://rosettacode.org/wiki/Quickselect_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
