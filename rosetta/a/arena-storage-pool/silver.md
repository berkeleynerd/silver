# Arena storage pool

**Candidate: proofs likely to discharge automatically.** The pool is modeled as an index-handled array arena with a visible exhaustion outcome, so every check follows from ranged subtypes and a guard before indexing, and no real heap, access type or Storage_Pool is needed.

Position 594 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

The arena is a record holding a fixed-capacity array of ranged Integer cells (say 1024) and a Free counter; an Allocate procedure hands out the next cell index as a handle and reports Success=False when the arena is full, and a Release procedure resets Free to free all objects as a group. The main procedure allocates cells for 1 and 2, stores their sum in a third cell, prints the values via Integer'Image, releases the arena, and shows that allocation succeeds again, with explicit guards on every handle use. About 70 lines.

## Proof obligations to watch

- **initialization**: Out parameters of Allocate are assigned on both the success and the exhaustion path, and the arena record is fully initialized at declaration.
- **index**: Allocate checks that Free is within capacity before indexing Core, so the index check follows from the guard just before the access.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, records, for loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the allocated values, their sum and the arena usage with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 399848 of the [task](https://rosettacode.org/wiki/Arena_storage_pool) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
