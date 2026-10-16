# Rendezvous

**Excluded from Silver: outside SPARK, annotations.** The required task rendezvous remains outside the pinned SPARK profiles, and the required cross-call Out_Of_Ink propagation needs exceptional contracts that Silver program authors cannot supply.

## Language surface recorded by this assessment

Tasking, string operations, characters, loops, subprograms and integers.

## Oracle conflicts

- **outside SPARK**: The task's core requirement is to demonstrate rendezvous: task entries, accept statements, requeue and timed entry calls. SPARK supports tasking only under the Ravenscar/Jorvik profiles, which allow no task entries, so it rules out rendezvous and requeue. The language task also says that if the language lacks rendezvous, they are to be built from other primitives. That would mean blocking entries with parameters that callers from several tasks can use. Ravenscar/Jorvik protected objects cannot provide that, so the use case's printer monitor cannot be written faithfully in SPARK.
- **annotations**: The required Out_Of_Ink propagation across program-defined calls needs Exceptional_Cases contracts, which Silver authors cannot write.

## External effects

- **console output** (allowed): The printers print each line to standard output one character at a time, labelled with the printer ID, and the writers report when they run out of ink.

Initially assessed on 2026-10-15 against page revision 412996 of the [task](https://rosettacode.org/wiki/Rendezvous) by claude-opus-5-5 at high effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-15 by Codex through targeted source review; see the [review record](../../review-343c2f8.md).
