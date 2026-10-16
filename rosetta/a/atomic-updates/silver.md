# Atomic updates

**Excluded from Silver: annotations.** Each arithmetic and range check can be made safe with declared ranges and clamp guards, but the task's required concurrency needs tasks and a protected object, which SPARK accepts only under a Ravenscar or Jorvik profile pragma that Silver source cannot contain.

## Approach

A library package declares a protected object holding a 13-element array of bounded bucket values, with Get, Snapshot and a Transfer procedure that clamps the amount by if guards to keep both buckets within 0 and capacity. Two infinite-loop tasks pick bucket pairs with a modular linear congruential generator and call Transfer to equalize or scatter, while a third task loops over Snapshot and prints each value and the total. About 110 lines.

## Proof obligations to watch

- **tasking**: Atomic transfers need a protected object and three library-level tasks, which SPARK only analyzes under a profile pragma that Silver forbids, so no admitted program can be proved.
- **overflow**: Without an invariant the prover cannot know the total is preserved, so the receiving bucket's addition discharges only if the transfer is also clamped to a declared bucket capacity at least the fixed total, which never activates in practice.
- **range**: The clamped increment between -Data(J) and Data(I) keeps both buckets non-negative through explicit if guards before each update.
- **overflow**: The displayed sum of 13 buckets fits because each bucket is bounded by a declared range whose 13-fold product lies within Integer.

## Language surface recorded by this assessment

Integers, integer division, modular types, ranged subtypes, arrays, for loops, while loops, procedures, functions, packages, tasking, 'Image of scalars and Put without a newline.

## Oracle conflicts

- **annotations**: The task requires concurrent tasks sharing a bucket object, and SPARK admits tasks and protected objects only under a Ravenscar or Jorvik profile pragma, which Silver source can never contain.

## External effects

- **console output** (allowed): The display task prints each bucket value and the preserved total.

Assessed on 2026-10-15 against page revision 413337 of the [task](https://rosettacode.org/wiki/Atomic_updates) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
