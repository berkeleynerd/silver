# Variadic fixed-point combinator

**Excluded from Silver: outside SPARK.** The task (marked 'requires First class functions') asks for a variadic combinator that takes functionals and returns their fixed points as new function values. That needs closures or run-time function construction, which Ada/SPARK cannot express. Writing the mutual recursion directly, as the FreeBASIC entry does, does not implement the combinator.

## Language surface beyond today's Silver

Subprograms, recursion, generics, integers and arrays.

## Oracle conflicts

- **outside SPARK**: The task requires a higher-order function fix* that takes n functions (each mapping functions to a function) and returns n new function values, the fixed points. That means building functions at run time and returning them as values, which needs closures or first-class functions. Ada/SPARK cannot express that: SPARK's access-to-subprogram values can only point to subprograms declared ahead of time and cannot capture arguments, and generic instantiation happens at compile time, so it cannot apply itself recursively.

## External effects

- **console output** (allowed): Print example results, such as even/odd tests on small integers, computed through the fixed points.

Assessed on 2026-10-15 against page revision 414571 of the [task](https://rosettacode.org/wiki/Variadic_fixed-point_combinator) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
