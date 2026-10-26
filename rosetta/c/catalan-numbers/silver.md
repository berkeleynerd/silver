# Catalan numbers

**Candidate: proofs plausibly discharge automatically.** The task is plain bounded integer arithmetic with 15 iterations, and the overflow and range checks discharge from the wide temporary type plus an explicit guard before the assignment. Nonlinear multiply and divide on loop-carried values make it depend on careful program shape rather than being routine.

Position 152 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Use the iterative recurrence C_n = C_(n-1)*2*(2n-1)/(n+1) in a single for loop over 0..15 inside Main, keeping the running value in a ranged subtype and printing each index and value with Put_Line of concatenated 'Image text. The next value is computed in a wide temporary type, guarded against the subtype maximum with a Reject branch, then assigned, so no check depends on a loop invariant. About 30 lines.

## Proof obligations to watch

- **overflow**: The product Result*2*(2*I-1) is safe only because Result has a ranged subtype (up to 2**40) in a 64-bit intermediate type, so the bound comes from the type rather than from a loop invariant.
- **range**: Assigning the quotient back to the ranged accumulator would fail the range check without an invariant, so the program computes the quotient in a wide temporary and guards it against the subtype maximum, with a visible Reject branch that never fires for N up to 15.
- **division**: The divisor I+1 is at least 2 because I is a for-loop index in 1..15, which is routine.
- **length**: Building the 'N = value' output line needs a bounded buffer sized for the largest Image text, which is routine once the lengths are statically bounded.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the first 15 Catalan numbers, one per line.

Assessed on 2026-10-15 against page revision 414105 of the [task](https://rosettacode.org/wiki/Catalan_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
