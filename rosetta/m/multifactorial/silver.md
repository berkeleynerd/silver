# Multifactorial

**Candidate: proofs likely to discharge automatically.** All arithmetic is over tiny declared ranges and the only loop-carried value, the product, is protected by a guard right before the multiply, so every check follows from types and guards with no annotations.

Position 305 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A function MultiFact(Num in 1..10, Deg in 1..5) starts Result at Num and runs a for loop over K in 1..9, computing N := Num - K*Deg and multiplying into Result only when N > 0, after a guard against overflow that rejects instead of altering the result. The main body uses nested for loops over degree and number, prints 'Degree' & Integer'Image(Deg) & ':' with Put and then each value via Put of Integer'Image, ending each row with a line terminator. There is no recursion, no while loop and the data is embedded as loop bounds. About 30 lines.

## Proof obligations to watch

- **overflow**: The accumulator is loop-carried, so a guard 'if Result > Integer'Last / N then reject' just before each multiplication makes the product check discharge without an invariant, and the real values never exceed 10! so the guard never fires.
- **overflow**: The term N = Num - K * Deg uses small declared ranges (Num 1..10, Deg 1..5, K 0..9) so the nonlinear product and subtraction stay in range by types alone.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The table of five degree rows is written to standard output.

Assessed on 2026-10-15 against page revision 413795 of the [task](https://rosettacode.org/wiki/Multifactorial) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
