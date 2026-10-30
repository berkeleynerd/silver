# Singly-linked list/Reversal

**Candidate: proofs likely to discharge automatically.** Index-based linked lists in a bounded array are plain SPARK: every access is bounded by the index subtype or an explicit Null guard, and no loop carries a fact that needs an invariant. The task is trivial and the loops sit in procedures, so proofs should discharge automatically.

Position 595 in the [progression](../../../progression.md#stage-11), in stage 11.

## Approach

Represent the singly-linked list as a fixed-capacity array of node records (a word as a fixed-length String plus a Next index into the array, with 0 meaning Null) and a Head index, filled with the embedded words Big, fjords, vex, quick, waltz, nymph. A procedure reverses in place with the standard prev/cur/next pointer-flip loop, with every dereference guarded by a not-Null test, and a printing procedure walks the links using Put and Put_Line before and after reversal. About 70 lines.

## Proof obligations to watch

- **index**: Link traversal indexes a fixed-capacity node pool; links use a subtype with a Null value 0 and each dereference is guarded by a test against Null, so index checks discharge from types and guards.
- **termination**: The traversal and in-place reversal loops live in procedures, which get no termination check, and a for loop bounded by the pool capacity could replace the while loop.

## Language surface recorded by this assessment

Ranged subtypes, arrays, records, for loops, while loops, procedures, Put without a newline, string building, integers and Boolean objects.

## External effects

- **console output** (allowed): Prints the list before and after reversal.

Assessed on 2026-10-15 against page revision 406900 of the [task](https://rosettacode.org/wiki/Singly-linked_list/Reversal) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
