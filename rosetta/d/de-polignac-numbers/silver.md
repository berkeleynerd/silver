# De Polignac numbers

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded by declared ranges and the search ceiling, and the loops are for loops, so checks follow from types and guards; the plausibility rating reflects nonlinear D*D and the loop-carried counter needing careful guards.

Position 379 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A function Is_Prime(N) uses a for loop over divisors 2..600 guarded by D*D <= N and N mod D = 0, and Is_De_Polignac loops K in 0..18 testing 2**K < N and Is_Prime(N - 2**K). Main loops I over a fixed range of odd candidates N = 2*I+1, counting results in a bounded Count, saving the first fifty in a constrained array and the 1000th and 10000th in variables, then prints them via 'Image and Put_Line/Put. If the 10000th is not found within the ceiling a specified message is printed. About 70 lines.

## Proof obligations to watch

- **overflow**: Candidate N = 2*I+1 for I in a declared range up to 200000 and P = 2**K for K in 0..18 stay far inside Integer, and N-P is guarded by P < N so it is positive.
- **termination**: Primality uses a for loop over D in 2..600 with an if D*D <= N guard instead of a while loop, so the function needs no variant.
- **index**: The count of found numbers is a loop-carried value, so it is held in a subtype 0..10000 and each increment is guarded by Count < 10000, and the first-fifty array is written only when Count <= 50.
- **other**: Cost is about 200000 candidates times 19 powers times 600 trial divisions, which is a runtime concern but not a proof one; a fixed search ceiling means the program must visibly report if the 10000th is not reached.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, functions, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first fifty numbers in rows of ten plus the 1000th and 10000th numbers.

Assessed on 2026-10-15 against page revision 413684 of the [task](https://rosettacode.org/wiki/De_Polignac_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
