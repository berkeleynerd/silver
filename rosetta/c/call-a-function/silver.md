# Call a function

**Candidate: proofs likely to discharge automatically.** Every check follows from small declared operand ranges, for-loop indexes over the array's own range, and one overflow guard placed just before the accumulator update, so no annotation is needed. First-class functions and partial application are optional items and are covered by printed statements rather than access-to-subprogram types.

Position 983 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Main declares a parameterless function, a function with a fixed parameter list and a defaulted optional parameter over a small ranged subtype, a procedure with in, out and in out parameters, and a Sum procedure over an unconstrained array type standing in for variadic calls via aggregates of different lengths. Main calls each positionally, with named and mixed associations, in statement context (procedure) and expression context (function results in expressions), uses Integer'Image as a built-in call, and prints lines stating parameter-passing modes and that partial application is not directly available. The Sum loop guards each addition and reports overflow through an out Boolean that Main prints. About 75 lines.

## Proof obligations to watch

- **overflow**: The variadic-style Sum over an unconstrained array of small-range items carries an accumulator through a for loop, so each addition is preceded by a guard against Integer'Last minus the item that sets an out Ok flag to False, which Main reports visibly.
- **range**: Functions with fixed, optional (defaulted) and named parameters take operands of a declared small subtype so their sums and products fit Integer by type alone.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, unconstrained arrays, arrays, for loops, functions, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Each call demonstration prints its returned value or an explanatory line with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 412692 of the [task](https://rosettacode.org/wiki/Call_a_function) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
