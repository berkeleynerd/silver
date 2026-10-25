# Farey sequence

**Candidate: proofs plausibly discharge automatically.** All values are small bounded integers and the recurrence is a simple loop in a procedure, so the only non-routine checks are the guarded nonlinear updates of loop-carried values, which discharge with explicit range guards. No annotation is needed.

Position 250 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

One procedure runs the next-term recurrence (k = (n+b)/d, then c' = k*c-a, d' = k*d-b) for a given order n, using small ranged integer subtypes for the four fraction values and a counter, with every update computed in a wider type and guarded before narrowing. For orders 1 to 11 it appends each fraction as n/d text into a bounded line buffer and prints the line with Put_Line, and for orders 100 to 1000 it prints only the count with the integer image. The main program loops over the required orders with for loops and embeds all constants. About 90 lines.

## Proof obligations to watch

- **range**: The next-term values k*c-a and k*d-b are loop-carried and nonlinear, so they are computed in a wider integer type and guarded to lie within 0..n (otherwise Reject) before narrowing to the ranged subtypes, which the provers can then discharge.
- **division**: The divisor d is a loop-carried value, so it is declared in a subtype that excludes zero and each update is guarded to stay at least 1 before assignment.
- **overflow**: The product k*c with both factors at most 1000 and k at most about 2000 fits easily in 64-bit Long_Long_Integer, so overflow follows from the declared type ranges.
- **termination**: The generation loop is a while loop in a procedure, which gets no termination check, or can be written as a for loop over a fixed maximum term count with an exit when the sequence reaches 1/1.
- **overflow**: The term counter reaches about 304193 and is a loop-carried value, so it is held in a range subtype with an explicit guard before each increment.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the Farey sequences for orders 1 to 11 and the fraction counts for orders 100 to 1000 by hundreds.

Assessed on 2026-10-15 against page revision 411852 of the [task](https://rosettacode.org/wiki/Farey_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
