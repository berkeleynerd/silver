# VList

**Candidate: proofs plausibly discharge automatically.** The task is a pure in-memory data structure demo that maps to index-based arrays instead of pointers, so only console output is needed and all checks follow from fixed capacities and guards. It is plausible rather than likely because the lookup and length walks carry block and offset indexes through loops with no invariants.

Position 631 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Represent the persistent VList over a fixed-capacity pool: an Integer element array plus a block table of records (base index, size, used count, predecessor block), with a list value being a (head block, offset) pair and block capacities doubling. Cons writes into the head block's free slot if it is the owner of the next slot, otherwise allocates a new double-size block, rejecting visibly when the pool is full; Nth, Rest (cdr, which just adjusts the offset or steps to the predecessor block) and Length walk the few blocks with bounded for loops guarded by range checks. Main builds a list, shows sharing via two lists with a common tail, and prints Nth, length and rest results with Put_Line and Put. About 130 lines.

## Proof obligations to watch

- **index**: Element lookup walks from the head block through predecessor links, so block and slot indexes are loop-carried and each is guarded by a range check or held in a subtype whose range fits the fixed pool.
- **overflow**: Counts, offsets and the doubling block sizes are small integers in declared ranges bounded by the fixed pool capacity, with an explicit full-pool rejection before every cons.
- **termination**: The block-walking loops are for loops over a fixed maximum block count (or while loops confined to procedures), so no variant is required.
- **initialization**: The element pool and block table must be fully initialized by aggregates so flow analysis sees no uninitialized reads.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The demonstration prints list contents, lengths and looked-up elements to standard output.

Assessed on 2026-10-15 against page revision 401203 of the [task](https://rosettacode.org/wiki/VList) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
