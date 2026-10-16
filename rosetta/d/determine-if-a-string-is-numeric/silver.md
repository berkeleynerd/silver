# Determine if a string is numeric

**Candidate: proofs likely to discharge automatically.** The hand-written scanner replaces the exception-based Float'Value, so no exception handling is needed, and every check follows from the for-loop range over Item'Range and a state subtype whose transitions assign only constants. No loop-carried arithmetic or annotation is needed, and the for loop terminates by itself inside the function.

Position 981 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Is_Numeric is a Boolean function taking an unconstrained String that runs a for loop over Item'Range driving a small state machine (optional sign, integer digits, point, fraction digits, optional exponent with sign and digits) held in a ranged-integer state variable with a dead state for invalid characters. After the loop it returns whether the final state is an accepting one, so the empty string and a lone sign are rejected explicitly. A procedure prints each embedded sample (such as "152", "-3.1415926", "Foo123") with its verdict through Put_Line and an if statement, with no input read. About 70 lines.

## Language surface recorded by this assessment

Boolean objects, characters, unconstrained arrays, string indexing, ranged subtypes, integers, for loops, procedures, functions and conditional expressions.

## External effects

- **console output** (allowed): Prints each embedded sample string with its numeric verdict via Put_Line.

Assessed on 2026-10-15 against page revision 412742 of the [task](https://rosettacode.org/wiki/Determine_if_a_string_is_numeric) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
