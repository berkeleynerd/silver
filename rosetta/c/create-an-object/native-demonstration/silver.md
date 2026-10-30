# Create an object/Native demonstration

**Candidate: proofs likely to discharge automatically.** Every index is of the key enumeration type and every value is a bounded Integer, so all checks follow from declared types and the for loop over the enumeration, and no loop-carried facts are needed. Ada has no magic methods, so the program only demonstrates the required fixed-key, reset-on-delete behavior, which the task treats as optional.

Position 1150 in the [progression](../../../progression.md#stage-19), in stage 19.

## Approach

Keys are a fixed enumeration type (for example Key_A, Key_B, Key_C), so no key can be added or removed. The object is a constant array of initial Integer values plus a mutable array of current values, both indexed by the key enumeration. Procedures Assign (key, value) and Delete (key) write the current array, with Delete copying the initial value back, and a for loop over the key type prints the state after each step. About 45 lines.

## Language surface recorded by this assessment

Enumerations, integers, arrays, for loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the dictionary contents before and after assignment, reset and the rejected-key outcome.

Assessed on 2026-10-15 against page revision 372281 of the [task](https://rosettacode.org/wiki/Create_an_object/Native_demonstration) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
