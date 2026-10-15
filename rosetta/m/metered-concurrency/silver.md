# Metered concurrency

**Excluded from Silver: delay.** The task requires concurrent units coordinated by a counting semaphore. SPARK can express this under the Jorvik tasking profile: library-level worker tasks and a protected object with an Acquire entry guarded by Count < Max, plus Release and Count operations. The guard proves the increment cannot overflow, and the decrement is guarded too, so no fixed Oracle rule is broken. Silver would first need tasking, protected types, delay and an output operation safe for concurrent tasks.

## Language surface beyond today's Silver

Tasking, integers, loops, subprograms and packages.

## External effects

- **console output** (allowed): Each worker task must report that it has acquired the semaphore. Several tasks print, so the output operation has to be safe to call from more than one task.
- **delay** (not allowed): Each worker must sleep for 2 seconds while it holds the semaphore, then release it.

Assessed on 2026-10-15 against page revision 412921 of the [task](https://rosettacode.org/wiki/Metered_concurrency) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
