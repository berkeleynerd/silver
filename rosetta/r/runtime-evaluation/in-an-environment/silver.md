# Runtime evaluation/In an environment

**Excluded from Silver: outside SPARK.** The task requires evaluating a program written in the host language, given as a string or AST, at run time with a runtime binding for x. Ada/SPARK cannot evaluate its own code at run time, so no Silver program can meet this task; the existing FreeBASIC solution only gets around this with an external expression-solver library.

## Language surface beyond today's Silver

Floating point and string operations.

## Oracle conflicts

- **outside SPARK**: The task requires taking a program written in the language itself (Ada/SPARK source or AST) and evaluating it at run time with x bound to supplied values. Ada/SPARK has no way to evaluate its own code at run time, and an interpreter for some other small expression language would not be 'a program in the language'.

## External effects

- **console output** (allowed): Prints the difference between the two evaluations.

Assessed on 2026-10-15 against page revision 410642 of the [task](https://rosettacode.org/wiki/Runtime_evaluation/In_an_environment) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
