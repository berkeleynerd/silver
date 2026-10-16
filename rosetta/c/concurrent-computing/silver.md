# Concurrent computing

**Excluded from Silver: clock, delay.** The arithmetic is trivial and would prove, but the task requires tasks or threads, which SPARK allows only under a Ravenscar/Jorvik profile pragma that Silver source cannot contain, and output from several tasks also needs synchronized I/O; for these reasons tasking makes the outlook unlikely.

## Approach

A library-level package declares three tasks, one per word, as Ravenscar/Jorvik requires; each task reads Ada.Real_Time.Clock and derives a small bounded delay from the clock value and its own index, using mod into a ranged subtype. It then does delay until on the start time plus that many milliseconds, and prints its word through a synchronized output operation, while the Main procedure body is null. About 45 lines.

## Proof obligations to watch

- **tasking**: The task requires real concurrency, and SPARK admits tasks and protected objects only under a Ravenscar or Jorvik profile pragma, which Silver source cannot contain, so admission would need a toolchain-supplied configuration rather than a proof.
- **other**: Three tasks calling Put_Line on the same output are concurrent access to shared state, so Silver_IO would need to be an admitted synchronized operation, or output would need to go through a protected object, before flow analysis accepts it.
- **overflow**: Turning the clock's seconds count into a delay in milliseconds is safe if the value is reduced with mod to a small ranged subtype before any multiplication.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, packages and tasking.

## External effects

- **console output** (allowed): Each of the three tasks prints its word on its own line.
- **clock** (not allowed): The clock supplies a per-run seed and the start time for each task's absolute delay, so the order differs between runs.
- **delay** (not allowed): Each task waits a pseudo-random interval (delay until, the form Ravenscar/Jorvik allows) before printing, which produces the random order.

Assessed on 2026-10-15 against page revision 415542 of the [task](https://rosettacode.org/wiki/Concurrent_computing) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
