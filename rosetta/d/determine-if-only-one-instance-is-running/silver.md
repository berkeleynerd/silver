# Determine if only one instance is running

**Excluded from Silver: OS services.** The program has no arithmetic, indexing or loops. Its only checks are Boolean branches on the results of the admitted lock and delete operations, so Bronze and Silver proofs discharge trivially once those operations exist with specified outcomes.

## Approach

Main calls an admitted library procedure that tries to atomically create a lock file with a fixed name and returns a Boolean out parameter saying whether it got the lock. If it did not, the program prints that another instance is already running and stops. If it did, it prints that it is the only instance, does its work, and calls an admitted delete on the lock file before exiting. About 25 lines.

## Proof obligations to watch

- **other**: Whether the program really detects a second instance rests on the admitted lock operation's environmental assumptions (atomic create, stale-lock handling), which proof cannot establish; the program's own checks are trivial.

## Language surface beyond today's Silver

Boolean objects and file output.

## External effects

- **console output** (allowed): Prints either an already-running message or a message that this instance is running.
- **files** (allowed): Atomically creates an exclusive lock file at a fixed name, reporting whether it already existed, and deletes it before exiting.
- **OS services** (not allowed): Single-instance detection depends on the operating system's atomic exclusive create, so the admitted lock operation must specify that assumption and what happens to a stale lock left by a killed instance.

Assessed on 2026-10-15 against page revision 413307 of the [task](https://rosettacode.org/wiki/Determine_if_only_one_instance_is_running) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
