# Doubly-linked list/Element removal

**Candidate: proofs likely to discharge automatically.** Everything is bounded array and index arithmetic over declared subtypes with explicit guards before each access, so all checks follow from types and guards without any invariants.

Position 607 in the [progression](../../../progression.md#stage-11), in stage 11.

## Approach

Nodes live in a fixed-capacity array of records (5-character padded String value, Prev and Next links of a 0..Capacity subtype, plus head and tail variables), built by an append procedure that rejects when full. A find function scans the array range comparing values, and a Remove procedure with a node index guard relinks the neighbours (updating head or tail when at an end) and marks the slot free. The main program appends cat, dog, hen, horse, prints the list by following Next links under a bounded for loop, removes "hen", then prints again. About 90 lines.

## Proof obligations to watch

- **index**: Link fields are a subtype 0..Capacity with 0 as the null link, so every array access is preceded by an explicit nonzero guard or uses a for-loop index over the array range.
- **termination**: List traversal uses a for loop bounded by Capacity (stopping early when the link is 0) in a procedure, so no while loop variant is needed.
- **range**: Removal rewrites neighbour links only after checking the target node is in use and its Prev and Next are nonzero, with the value-not-found case printing a visible message.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, records, string indexing, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The demonstration prints the list before and after removal.

Assessed on 2026-10-15 against page revision 406839 of the [task](https://rosettacode.org/wiki/Doubly-linked_list/Element_removal) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
