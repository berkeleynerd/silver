# Synchronous concurrency

**Excluded from Silver: outside SPARK.** The task needs two concurrent tasks, not processes, that communicate synchronously in both directions, and all of them must terminate cleanly. SPARK allows tasking only under Ravenscar/Jorvik, which forbid task termination, so no future Silver program could meet this requirement.

## Language surface recorded by this assessment

Tasking, loops, integers, string operations and packages.

## Oracle conflicts

- **outside SPARK**: The task requires two threads or tasks that communicate in both directions, and all of them must terminate cleanly when the program ends. SPARK only supports tasking under the Ravenscar or Jorvik profiles. Those profiles impose No_Task_Termination, and SPARK requires library-level task bodies never to complete. Ravenscar also bans task entries, select and terminate alternatives. So required clean termination of every concurrent unit is a construct SPARK excludes (Oracle rule 8). Enabling the profile at all also needs pragma Profile, a pragma beyond SPARK_Mode.

## External effects

- **files** (allowed): The reading unit opens the file input.txt and reads it one line at a time.
- **console output** (allowed): The printing unit writes each line it receives to standard output, and the reading unit then prints the line count.

Assessed on 2026-10-15 against page revision 413078 of the [task](https://rosettacode.org/wiki/Synchronous_concurrency) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
