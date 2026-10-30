# Blum integer

**Candidate: proofs likely to discharge automatically.** Everything is integer arithmetic over ranged subtypes with fixed-size arrays and loops whose bounds are guarded, so every check follows from types and guards without annotations; the only demands are a modest set of new surface features and explicit handling when the search limit is exceeded.

Position 784 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The program scans candidates N in a for loop up to a fixed limit, and a procedure with a bounded while loop finds the smallest prime factor by trial division with a ranged divisor. It accepts N when the smallest factor P and the cofactor Q differ, both are 3 mod 4, and Q has no smaller divisor (checked by a second bounded trial-division procedure), then records the first 50 in an array, prints the requested Nth values, and tallies final digits in a 4-element array. Percentages are computed in integer arithmetic as count*100000/400000 and printed with three decimals built into a bounded string. About 110 lines.

## Proof obligations to watch

- **overflow**: Candidate, divisor and counter variables are declared with ranged subtypes (candidate bounded by a fixed 10,000,000 limit, divisor by 4000), and every increment is preceded by a guard, so D*D and the percentage product count*100000 stay within Integer.
- **index**: The 50-entry result array and 4-entry digit-count array are indexed only after a guard on the running count or by a digit mapping from N mod 10 that the case statement confines to 1, 3, 7 or 9.
- **termination**: The trial-division while loop lives in a procedure (no termination check) and also exits when D exceeds the fixed bound, while the outer scan is a for loop.
- **other**: If the fixed search limit is reached before 400,000 Blum integers are found, the program must print a specified failure message rather than silently truncating, which an explicit guard on the count provides.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, case statements, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 50 Blum integers, the selected Nth values and the last-digit percentages as text.

Assessed on 2026-10-15 against page revision 414090 of the [task](https://rosettacode.org/wiki/Blum_integer) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
