# Reflection/List properties

**Excluded from Silver: outside SPARK.** The task asks for an object's properties to be listed through reflection, which is introspection of program structure that Ada/SPARK cannot express. Printing hand-picked fields would just be ordinary output and would not meet the reflection requirement, so this sample is excluded.

## Language surface recorded by this assessment

Records, tagged types and string operations.

## Oracle conflicts

- **outside SPARK**: The task is to discover and list an object's properties (names and/or values) through reflection, which is run-time introspection of program structure. Ada/SPARK has no reflection API for enumerating a type's components, and dynamic properties are not possible at all. Ada 2022's record 'Image is the closest thing, but it is only a fixed compile-time image, and SPARK's support for it on composite types is limited.

## External effects

- **console output** (allowed): Prints the property names and values it finds.

Assessed on 2026-10-15 against page revision 414440 of the [task](https://rosettacode.org/wiki/Reflection/List_properties) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
