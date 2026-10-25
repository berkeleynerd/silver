# First class environments

**Candidate: proofs plausibly discharge automatically.** Plain Ada record values meet the task's idea of a first-class environment, and every check is routine apart from the two loop-carried increments. Explicit guards placed just before those increments discharge them, and the unbounded while loop is in a procedure, so no annotation is needed.

Position 613 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Each environment is a record with Value and Count components, which Ada can construct, assign, pass and return as an ordinary value. The program keeps an array of 12 such records initialized to (I, 0), and one Step procedure with an in out environment parameter forms the single piece of code. That procedure prints the right-aligned Value with Put and 'Image, and if Value /= 1 it guards against overflow, increments Count and applies the hailstone rule using mod and /. Main repeats rounds in a while loop until a Boolean all-done scan over the array finds every Value = 1, then prints each Count. About 60 lines.

## Proof obligations to watch

- **overflow**: The loop-carried 3*Value+1 and Count+1 are bounded only by their types, so the step procedure must test Value <= (Integer'Last - 1) / 3 and Count < Integer'Last just before the arithmetic and report a visible overflow outcome otherwise (this never happens for the seeds 1 to 12, whose peak is 52).
- **termination**: The outer while loop runs until every environment reaches 1, and it sits in the Main procedure, where GNATprove issues no termination check.
- **initialization**: The array of environment records is fully initialized by an aggregate or a for loop over its own range before the first round, which flow analysis accepts when written as a single aggregate.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, records, arrays, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the table of hailstone values, one row per round, and then the final step counts.

Assessed on 2026-10-15 against page revision 414210 of the [task](https://rosettacode.org/wiki/First_class_environments) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
