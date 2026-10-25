# Currying

**Candidate: proofs likely to discharge automatically.** Currying is expressed the Ada way, as partial application through nested generic instantiation with no closures or access-to-subprogram values. The only non-trivial check is the addition in Sum, and the operands' declared subtype bounds it, so every check follows from types and static values.

Position 1517 in the [progression](../../progression.md#stage-30), in stage 30.

## Approach

A generic package Curry_3, which takes a generic formal function Func, holds nested generic packages Apply_1 (formal object First) and Apply_2 (formal object Second). Apply_2 exports a function Apply_3 (Third) that returns Func (First, Second, Third), so partial application is done by instantiation. Main instantiates the generic with a Sum over a bounded subtype, then with 5 and then 7, and prints Apply_3 (3) through Put_Line with 'Image and a short historical note, with no loops, recursion or guards needed. About 45 lines.

## Proof obligations to watch

- **overflow**: The three-argument Sum takes parameters of a declared small subtype (for example -1000 .. 1000) and returns Integer, so X + Y + Z cannot overflow whatever the arguments.
- **range**: Instance actuals and call arguments are static literals inside the small subtype, so the range checks at instantiation and at each call discharge statically.

## Language surface recorded by this assessment

Integers, ranged subtypes, functions, generics, packages and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the result of applying the curried function, along with a short note on how Ada approximates currying with generics.

Assessed on 2026-10-15 against page revision 415329 of the [task](https://rosettacode.org/wiki/Currying) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
