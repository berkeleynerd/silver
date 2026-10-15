# Runtime evaluation

**Excluded from Silver: outside SPARK.** This task asks a program to show it can run code in its own language that is given to it at run time. Ada/SPARK has no such facility, and Silver may not add one, so the sample is excluded as outside SPARK.

## Language surface beyond today's Silver

String operations.

## Oracle conflicts

- **outside SPARK**: The task requires a program to execute code written in its own language that is supplied at run time (an eval facility). Ada/SPARK cannot evaluate source code at run time. Rule 1 forbids adding such a facility, and calling a separate evaluator or compiler is ruled out by both the task and rule 6.

## External effects

- **console output** (allowed): Prints the results of the code it evaluates.

Assessed on 2026-10-15 against page revision 411436 of the [task](https://rosettacode.org/wiki/Runtime_evaluation) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
