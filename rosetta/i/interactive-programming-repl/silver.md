# Interactive programming (repl)

**Excluded from Silver: outside SPARK.** The task asks how to start the language's built-in interactive mode (REPL) and how to define a function in it, which means evaluating code typed in at run time. Ada/SPARK has no such mode, and the task rules out writing your own, so it is excluded. The string function itself (s1 & sep & sep & s2) would be easy, but a compiled program like the FreeBASIC one does not do what the task asks.

## Language surface recorded by this assessment

String operations and subprograms.

## Oracle conflicts

- **outside SPARK**: The task requires starting the language implementation's interactive mode (a read-eval-print loop) and defining a function interactively, i.e. evaluating source code entered at run time. Ada/SPARK is a compiled language with no interactive mode, and the task explicitly says it is not about writing your own interpreter, so no Silver program can meet it.

## External effects

- **standard input** (allowed): An interactive session reads lines the user types.
- **console output** (allowed): The session prints results such as 'Rosetta::Code'.

Assessed on 2026-10-15 against page revision 412593 of the [task](https://rosettacode.org/wiki/Interactive_programming_%28repl%29) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
