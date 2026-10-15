# Y combinator

**Excluded from Silver: outside SPARK.** Excluded. The task asks for a stateless fixed-point combinator that turns non-recursive functions into recursive ones, which requires first-class functions and closures. Ada/SPARK cannot express those, and the FreeBASIC entry gets around this only by not implementing a real combinator.

## Language surface beyond today's Silver

Integers, subprograms, recursion and access types.

## Oracle conflicts

- **outside SPARK**: The task requires defining a stateless Y combinator, a higher-order function that takes a function and returns its recursive fixed point. This needs first-class functions, lambda expressions and closures that capture arguments of enclosing functions, plus self-application. Ada/SPARK cannot express these: there are no anonymous functions or closures, and SPARK limits access-to-subprogram values, so a function cannot build and return a new function at run time.

## External effects

- **console output** (allowed): Prints the factorial and Fibonacci values computed through the combinator.

Assessed on 2026-10-15 against page revision 414995 of the [task](https://rosettacode.org/wiki/Y_combinator) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
