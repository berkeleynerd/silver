# Introspection

**Excluded from Silver: outside SPARK, environment.** Excluded: the task needs a running program to test whether the variable bloop and the function abs exist, and to read its own compiler or runtime version. Both are introspection that Ada/SPARK cannot express, because names are resolved at compile time. The existing Ada solution admits this and prints target type limits instead.

## Language surface recorded by this assessment

Integers.

## Oracle conflicts

- **outside SPARK**: The core task asks the program to check while it runs whether a variable named "bloop" and a function "abs" exist, and to call abs only if they do. That is introspection of the program's own structure. Ada/SPARK settles name resolution at compile time, so a program that names a missing entity is rejected instead of running and reporting it is missing. Ada also gives no portable way to ask for the version of the running compiler or runtime.

## External effects

- **environment** (not allowed): The program must look up the version of the compiler or runtime it is running under.
- **exit status** (allowed): The program must exit, with a failure status, when the version is too old.
- **console output** (allowed): The program prints the result of abs(bloop).

Assessed on 2026-10-15 against page revision 414270 of the [task](https://rosettacode.org/wiki/Introspection) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
