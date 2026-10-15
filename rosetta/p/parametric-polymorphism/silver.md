# Parametric polymorphism

**Candidate: proofs likely to discharge automatically.** The parametric type and its map need only a generic package, a fixed-size array and a for loop, with no pointers or recursion. Every index comes from the array's own range and the mapped function's result is bounded by a symmetric declared range, so all checks are routine.

Position 1526 in the [progression](../../progression.md#stage-31), in stage 31.

## Approach

A generic package with a private Element_Type formal and a formal function F declares Tree as a fixed array indexed by Node_Index range 1 .. 7, holding a complete binary tree in heap layout where the children of node I are 2I and 2I+1. Its procedure Map uses a for loop over Node_Index to replace every element with F applied to it. Main instantiates the package with a bounded integer subtype and a negation function, builds the tree from an aggregate, and prints each element with 'Image before and after Map. About 45 lines.

## Proof obligations to watch

- **overflow**: The integer function mapped over the instance (for example negation) acts on a symmetric declared range such as -1000 .. 1000, so its result stays within the element type.
- **other**: GNATprove proves the generic body once per instance, so the single Integer-range instance has only routine checks: the for loop over Node_Index applies the formal function to each element in place.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops, procedures, functions, generics, packages and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the tree's elements before and after mapping a function over them.

Assessed on 2026-10-15 against page revision 414380 of the [task](https://rosettacode.org/wiki/Parametric_polymorphism) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
