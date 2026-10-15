# Extend your language

**Excluded from Silver: outside SPARK.** The task asks a language to define a new control-flow keyword (if2/else1/else2) that behaves like its built-in if. That is syntax extension, which Ada/SPARK cannot express and the Oracle forbids. The Ada entry's case-over-function workaround imitates the behaviour but adds no new language construct.

## Language surface beyond today's Silver

Integers, enumerations, subprograms and loops.

## Oracle conflicts

- **outside SPARK**: The task's core requirement is to extend the language with a new flow-control keyword (if2 with else1/else2) that looks, nests and behaves like the built-in if. Ada/SPARK has no macros or user-defined syntax, and Oracle rule 1 says Silver never adds syntax. A case statement over a helper function, which is what the Ada entry does, only emulates the construct; it does not introduce one.

## External effects

- **console output** (allowed): A demonstration would print which of the four branches ran.

Assessed on 2026-10-15 against page revision 413178 of the [task](https://rosettacode.org/wiki/Extend_your_language) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
