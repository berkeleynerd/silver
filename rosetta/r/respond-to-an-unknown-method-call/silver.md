# Respond to an unknown method call

**Excluded from Silver: outside SPARK.** Not a candidate. The task requires calling a method the class does not define, with dynamic dispatch and no static checking. Ada/SPARK rejects such a call when compiling, and the task explicitly rules out the workaround of looking a method up by its name in a string.

## Language surface recorded by this assessment

Tagged types.

## Oracle conflicts

- **outside SPARK**: The task requires an object to respond when code invokes a method that its class does not define, and it says this is only for dynamically dispatched systems without static checking. In Ada/SPARK, calling an undeclared primitive operation is a compile-time error, and there is no hook like method_missing or doesNotUnderstand. The task also rules out the only legal substitute: dispatching on a method name held in a string, which it explicitly says is a different thing.

## External effects

- **console output** (allowed): The program prints the object's response to the unsupported call.

Assessed on 2026-10-15 against page revision 408491 of the [task](https://rosettacode.org/wiki/Respond_to_an_unknown_method_call) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
