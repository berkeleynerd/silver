# Mutex

**Excluded from Silver: annotations.** The task is purely about concurrent mutual exclusion, so it needs tasks and protected objects, and SPARK admits those only under a Ravenscar or Jorvik profile pragma that Silver source cannot contain. On top of that, GNATprove's race analysis would not credit a hand-built mutex protocol.

## Approach

A library package declares a protected type Mutex with a private Boolean Owned, an entry Seize whose barrier is "when not Owned", and a procedure Release. Two library-level tasks each run a bounded for loop that seizes the mutex, prints a line identifying the task and releases the mutex. No guards are needed beyond the entry barrier. About 55 lines.

## Proof obligations to watch

- **tasking**: GNATprove's concurrency analysis needs a library-level task profile that only a forbidden pragma can declare.
- **tasking**: GNATprove cannot see the Seize/Release protocol, so it reports a data race when two tasks share the output resource that the mutex protects; it accepts shared state only when that state lives inside a protected object, which defeats the point of the mutex.
- **termination**: Ravenscar and Jorvik tasks are expected never to terminate, so the demonstration program cannot reach a specified, completed end state.

## Language surface recorded by this assessment

Tasking, packages, Boolean objects, integers, for loops and procedures.

## Oracle conflicts

- **annotations**: A mutex only means something between concurrent tasks, and SPARK admits tasks and protected objects only under pragma Profile (Ravenscar or Jorvik) plus pragma Partition_Elaboration_Policy, which Rule 3 forbids in Silver source.

## External effects

- **console output** (allowed): Each task prints a line while it holds the mutex, which shows that the critical sections never interleave.

Assessed on 2026-10-15 against page revision 412935 of the [task](https://rosettacode.org/wiki/Mutex) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
