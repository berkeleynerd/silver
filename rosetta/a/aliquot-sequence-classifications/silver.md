# Aliquot sequence classifications

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared ranges, loop-index bounds and a guard on the divisor-sum accumulator, but the loop-carried sum and bounded string assembly require careful program shape, and the optional 15355717786080 case is omitted.

Position 412 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Terms are held in a 16-element array of a 64-bit subtype, with embedded input numbers; a function sums proper divisors by trial division up to sqrt(n) with the for-loop and a sum cap, and a procedure generates terms, checking for zero, perfect, amicable, sociable, aspiring, cyclic or a term above 2**47 with 16-term cutoff. A procedure then builds the classification and comma-separated sequence line in a bounded buffer using 'Image and prints it with Put_Line. About 130 lines.

## Proof obligations to watch

- **overflow**: The divisor-sum accumulator is loop-carried, so each addition is preceded by a guard that stops the sum once it exceeds a bound near 2**50, which only yields the task's own non-terminating outcome because any term above 2**47 is non-terminating.
- **termination**: Trial division uses a for loop over a fixed range with an early exit when d*d exceeds n, so no while loop sits inside a function, and any while loops live in procedures.
- **overflow**: The d*d test and n/d are nonlinear but are bounded because d is within a declared 24-bit-scale range and n is in a subtype capped at 2**47.
- **length**: Each output line is assembled in a fixed buffer sized for 16 terms of up to 15 digits plus separators and the label, with index guards before every append.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the classification and sequence line for each of the 23 required numbers.

Assessed on 2026-10-15 against page revision 413632 of the [task](https://rosettacode.org/wiki/Aliquot_sequence_classifications) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
