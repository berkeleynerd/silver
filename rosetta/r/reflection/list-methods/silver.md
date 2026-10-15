# Reflection/List methods

**Excluded from Silver: outside SPARK.** The task is listing an object's methods through reflection. Ada/SPARK cannot inspect program structure this way, so no future Silver can cover it. The FreeBASIC solution admits it lacks reflection and only prints a hard-coded table.

## Language surface beyond today's Silver

Tagged types and string operations.

## Oracle conflicts

- **outside SPARK**: The task asks a program to get the methods of an object at run time through reflection, as names, values or both. Ada/SPARK has no way to inspect a type's primitive operations, and it has no first-class method values that a program could enumerate. A hand-written list of names, like the FreeBASIC solution's, does not perform the introspection the task asks for.

## External effects

- **console output** (allowed): The program prints the method names it finds.

Assessed on 2026-10-15 against page revision 414439 of the [task](https://rosettacode.org/wiki/Reflection/List_methods) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
