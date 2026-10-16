# Send an unknown method call

**Excluded from Silver: outside SPARK.** Not a candidate. The task's core requirement is to call an object method whose name is only known at run time, which is reflective dispatch by name. Ada/SPARK has no way to express that, and a hand-written lookup table would not meet the task as stated.

## Language surface recorded by this assessment

String operations, tagged types and subprograms.

## Oracle conflicts

- **outside SPARK**: The task requires invoking an object method chosen by a name generated at run time. That needs reflection or dynamic lookup of methods by name. Ada/SPARK cannot do this: subprogram names are bound at compile time, and an author-written case over string literals only re-creates the mapping by hand, so it does not send an arbitrary method call.

## External effects

- **console output** (allowed): Prints the result of the method that was invoked dynamically.

Assessed on 2026-10-15 against page revision 413223 of the [task](https://rosettacode.org/wiki/Send_an_unknown_method_call) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
