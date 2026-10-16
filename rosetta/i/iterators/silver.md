# Iterators

**Candidate: proofs likely to discharge automatically.** Every check follows from declared index and length ranges plus a Cursor /= 0 guard before each dereference, and the list's while loop lives in a procedure, so no termination check or invariant is needed.

Position 614 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

The days are a constant array of seven records holding a padded String (1 .. 9) and its length, and the colors are an array-backed doubly linked list of node records with Next and Prev cursors of type 0 .. Capacity, where 0 means none. Separate cursor procedures (First, Last, Next, Previous) and an Element function give container-independent access, with all-element printing done by a for loop over the day array and a while loop over the list cursor inside a procedure. Positional access walks a for loop of K - 1 steps, guarding each step with Cursor /= 0 and printing a specified "no such element" line when the cursor runs off the end. About 110 lines.

## Proof obligations to watch

- **index**: Following a cursor of type 0 .. Capacity into the node array is preceded by an explicit Cursor /= 0 guard, so the conversion to the 1 .. Capacity index subtype and the indexing discharge from that guard alone.
- **range**: Each Name (1 .. Len) slice discharges because Len is a record component declared in 1 .. 9 and Name is String (1 .. 9), and the positional offsets (Count - K + 1) are computed with static K over a Count typed 0 .. Capacity and guarded with K <= Count before use.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, records, string indexing, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): The program prints each container's elements and the selected first, fourth, fifth and last, fourth-to-last and fifth-to-last elements to standard output.

Assessed on 2026-10-15 against page revision 415004 of the [task](https://rosettacode.org/wiki/Iterators) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
