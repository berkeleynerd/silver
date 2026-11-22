# Tau number

**Candidate: proofs likely to discharge automatically.** Every check follows from ranged subtypes and guards just before each increment, and the only loops that need termination (while) sit in a procedure. The 100th Tau number is 1096, so a 2000 bound is ample, and the nested loops need no invariants.

Position 337 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A Main procedure runs a while loop with a candidate n in a ranged subtype 1..2000 and a found-count, stopping at 100 found or when the candidate bound is reached. For each n, a divisor-counting loop uses a for loop over 1..n with a ranged counter incremented only after a guard; n mod count = 0 selects Tau numbers, which are printed with 'Image and Put, with a Put_Line newline after every tenth. Division by the count is safe because the count is always at least 1 (the divisor 1 always counts). About 45 lines.

## Proof obligations to watch

- **overflow**: The divisor counter is a loop-carried value, so it is a ranged subtype with a guard before each increment, which can never trigger for candidates up to the bound.
- **range**: The candidate and found-count variables are loop-carried, so they are ranged subtypes bounded by the largest needed value (1096, with a margin) and a guard before each increment.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, while loops, procedures, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the 100 Tau numbers, ten per line, to standard output.

Assessed on 2026-10-15 against page revision 414543 of the [task](https://rosettacode.org/wiki/Tau_number) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
