# Factorial

**Candidate: proofs plausibly discharge automatically.** Iterative factorial over a ranged argument with a division-based guard on the accumulator needs no annotation, but the nonlinear loop-carried multiply makes discharge depend on program shape rather than being routine.

Position 159 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Declare subtype Arg is Integer range 0 .. 20 and subtype Fact is Long_Long_Integer range 1 .. 20!, and an iterative procedure Factorial (N : Arg; Result : out Fact; Ok : out Boolean) with a for loop from 2 to N, each step guarded by Result <= Max / I before multiplying, setting Ok false otherwise. Main loops N over 0 .. 20 calling it and printing "N! = value" with Put_Line, reporting an overflow line if Ok is false; negative n is excluded by the argument type, and larger n is outside the documented limit of 20. About 35 lines.

## Proof obligations to watch

- **overflow**: The loop-carried product Result * I is known only by its subtype range, so the program guards it with Result <= Max / I just before the multiply, which provers can discharge with a constant Max, and the else branch reports failure visibly.
- **range**: The result subtype 1 .. 20! and the argument subtype 0 .. 20 make assignments and the 'Image conversion routine checks follow from declared ranges.
- **length**: Concatenating a literal with two 'Image results into Put_Line needs a bound on the image lengths, which follow from the ranged subtypes (at most 2 and 19 digits).

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, procedures, 'Image of scalars, string building and Boolean objects.

## External effects

- **console output** (allowed): Prints each n and n! as a line of text via Put_Line.

Assessed on 2026-10-15 against page revision 415532 of the [task](https://rosettacode.org/wiki/Factorial) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
