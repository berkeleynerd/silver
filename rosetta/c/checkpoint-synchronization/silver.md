# Checkpoint synchronization

**Excluded from Silver: annotations.** The task is inherently about synchronizing concurrent tasks, which SPARK allows only under a Ravenscar or Jorvik pragma that Silver forbids, and a sequential simulation would not be a faithful solution.

## Approach

A library package would declare a protected Checkpoint with a ready count, worker count and generation number, an Arrive procedure and a Wait entry whose barrier opens when the generation advances, plus an array of library-level worker tasks labeled by Character. Each worker would loop for a fixed number of cycles printing working and ready lines, call the checkpoint, and then idle, with counters guarded by declared ranges. About 90 lines.

## Proof obligations to watch

- **tasking**: Library-level worker tasks and a protected checkpoint object with a generation counter need the Jorvik profile, and concurrent calls to a shared output library would be rejected as unprotected shared state unless Silver_IO were itself a task-safe admitted operation.
- **overflow**: The arrival count and cycle counter inside the protected object are loop-carried across entries, so they need declared ranges with explicit wraparound or reset guards before each increment.
- **termination**: Ravenscar and Jorvik forbid task termination, so workers must loop forever or idle after a fixed number of cycles, leaving a program that never exits.

## Language surface recorded by this assessment

Tasking, packages, integers, ranged subtypes, Boolean objects, characters, arrays, for loops, while loops and procedures.

## Oracle conflicts

- **annotations**: The task requires real concurrent tasks synchronizing at a checkpoint, and SPARK admits tasks and protected objects only under a pragma Profile (Ravenscar or Jorvik), which Silver source is forbidden to contain.

## External effects

- **console output** (allowed): Workers report working, ready and sync-point events as text lines.

Assessed on 2026-10-15 against page revision 412050 of the [task](https://rosettacode.org/wiki/Checkpoint_synchronization) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
