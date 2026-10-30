# Short-circuit evaluation

**Candidate: proofs likely to discharge automatically.** The program only branches on Booleans, loops over Boolean'Range and prints fixed literals, so it has no arithmetic, indexing or loop-carried values for a check to fail on, and procedures need no termination proof. Initialization of the out parameters and of x and y on every path follows directly from data flow.

Position 101 in the [progression](../../progression.md#stage-5), in stage 5.

## Approach

Because a SPARK function cannot print, a and b are procedures that print their name and copy their Boolean input to an out parameter. Main uses nested for loops over Boolean for i and j and gets x = a(i) and b(j) and y = a(i) or b(j) with nested if statements, so b runs only when a's result leaves the answer open, which the task explicitly allows. Results are printed by if statements that choose between the literal texts "True" and "False", and the program needs no guards. About 55 lines.

## Language surface recorded by this assessment

Boolean objects, procedures and for loops.

## External effects

- **console output** (allowed): Each call to a or b prints its name, and every computed x and y value is printed.

Assessed on 2026-10-15 against page revision 413227 of the [task](https://rosettacode.org/wiki/Short-circuit_evaluation) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
