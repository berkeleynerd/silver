# Doubly-linked list/Element insertion

**Candidate: proofs likely to discharge automatically.** The task is plain pointer rewiring that maps onto array indices with a null sentinel, so every check follows from index subtypes and guards placed just before each use. Traversal uses a bounded for loop over the pool, so no termination or loop-carried-value obligations arise.

Position 1159 in the [progression](../../../progression.md#stage-19), in stage 19.

## Approach

Represent the list as a fixed-capacity array of node records (Data, Next, Prev) using index subtypes with 0 as null instead of access types. An Insert procedure guards null/invalid anchors, sets New.Next and New.Prev from the anchor, fixes the successor's Prev if it exists, then sets Anchor.Next; main builds {A,B}, inserts C after A, and walks forward with a bounded for loop printing each element via Put_Line. About 70 lines.

## Proof obligations to watch

- **index**: Links are indices into a fixed-capacity node pool with a Null_Link sentinel, so every dereference is guarded by an explicit not-null test and the index subtype covers the pool range.
- **range**: The Insert procedure rejects a null anchor or null new link and a full pool with a visible outcome (reported by a printed message), so no index falls outside the pool.

## Language surface recorded by this assessment

Ranged subtypes, enumerations, arrays, records, procedures, functions, for loops, while loops, integers, Boolean objects, characters and Put without a newline.

## External effects

- **console output** (allowed): The program prints the resulting list order (A, C, B) to show the insertion worked.

Assessed on 2026-10-15 against page revision 412752 of the [task](https://rosettacode.org/wiki/Doubly-linked_list/Element_insertion) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
