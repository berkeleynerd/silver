# Accumulator factory

**Excluded from Silver: outside SPARK.** Not a candidate. The task's core requirement is a run-time factory that returns a real function holding its own private mutable state (a closure) with dynamically chosen integer or float results. Ada/SPARK cannot express this, and the Ada workaround of generic instantiation relies on compile-time package-global state that the task explicitly rules out.

## Language surface beyond today's Silver

Integers, floating point, subprograms, access types and records.

## Oracle conflicts

- **outside SPARK**: The task requires a factory that, at run time, takes a number and returns a new first-class function with its own captured, private mutable state (a closure) that can be used wherever an ordinary function can. Ada/SPARK cannot create functions at run time or capture state in them. Generic instantiation is fixed at compile time and keeps the sum as package-level global state, which rule 5 forbids. SPARK also does not allow functions to change state unless they carry a Side_Effects aspect, and the Oracle bans annotations.
- **outside SPARK**: The returned function must accept both integers and floats and choose its result type from what it has seen so far: integer while only integers have been passed, float after that. A value whose type changes at run time like this is dynamic typing, not static overloading.

## External effects

- **console output** (allowed): Prints the accumulated value from the example sequence (for example 8.3).

Assessed on 2026-10-15 against page revision 414999 of the [task](https://rosettacode.org/wiki/Accumulator_factory) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
