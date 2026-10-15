# Rendezvous

**Excluded from Silver: outside SPARK, exception handling.** Rendezvous is excluded. The task requires task entries with accept and requeue between concurrent tasks (the two printer monitors and two writer tasks), which SPARK's Ravenscar/Jorvik tasking does not allow. It also requires an Out_Of_Ink exception to propagate to the caller, which SPARK and the Oracle forbid.

## Language surface beyond today's Silver

Tasking, string operations, characters, loops, subprograms and integers.

## Oracle conflicts

- **outside SPARK**: The task's core requirement is to demonstrate rendezvous: task entries, accept statements, requeue and timed entry calls. SPARK supports tasking only under the Ravenscar/Jorvik profiles, which allow no task entries, so it rules out rendezvous and requeue. The language task also says that if the language lacks rendezvous, they are to be built from other primitives. That would mean blocking entries with parameters that callers from several tasks can use. Ravenscar/Jorvik protected objects cannot provide that, so the use case's printer monitor cannot be written faithfully in SPARK.
- **exception handling**: The use case requires the Out_Of_Ink exception to propagate back to the caller when both printers are out of ink. The language task also requires exceptions to stay consistent with rendezvous, propagating in both tasks. SPARK forbids exception handlers, and Oracle rule 2 forbids raising exceptions at all.

## External effects

- **console output** (allowed): The printers print each line to standard output one character at a time, labelled with the printer ID, and the writers report when they run out of ink.

Assessed on 2026-10-15 against page revision 412996 of the [task](https://rosettacode.org/wiki/Rendezvous) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
