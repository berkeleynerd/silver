# Church numerals

**Excluded from Silver: outside SPARK.** Excluded. The task asks for natural numbers encoded as functions that apply their argument N times, plus successor and arithmetic operators that build new such functions at run time. That needs closures and first-class higher-order functions, which Ada/SPARK cannot express. Only printing the integer results would be Silver-friendly.

## Language surface recorded by this assessment

Integers, subprograms and generics.

## Oracle conflicts

- **outside SPARK**: Church numerals are, by definition, functions that take a function f and return a new function applying f N times. The successor, addition, multiplication and exponentiation operations must build new numerals at run time, so they return functions that capture other functions (closures, i.e. first-class higher-order functions). Ada/SPARK has no closures or lambdas, and SPARK restricts access-to-subprogram values, so the encoding cannot be expressed faithfully. Storing a plain integer or tagged record instead, as the FreeBASIC entry does, replaces the Church encoding with ordinary data and does not meet the task's definition.

## External effects

- **console output** (allowed): Prints the integer values of 3+4, 3*4, 4^3 and 3^4 after converting them back from Church numerals.

Assessed on 2026-10-15 against page revision 412705 of the [task](https://rosettacode.org/wiki/Church_numerals) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
