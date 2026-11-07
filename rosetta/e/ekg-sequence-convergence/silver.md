# EKG sequence convergence

**Candidate: proofs likely to discharge automatically.** Everything is bounded for loops over declared ranges with embedded data, and the only subtle spot is keeping candidate indexes within the fixed value limit by an explicit guard with a visible failure outcome, so proofs should discharge without annotations.

Position 899 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Each sequence is a constant-length array of 1..30 terms over a subtype of values 1..400, with a Boolean used-flag array of the same value range; a Generate procedure for each start fills terms by scanning candidates 2..400 with a for loop, picking the first unused one sharing a divisor above 1 (checked with a for loop over divisors using mod) with the previous term. Output goes through Put and Integer'Image into lines for the five starts, and convergence is found by a for loop over terms 3..30 comparing a(c) and the entire used-flag arrays of EKG(5) and EKG(7) as recorded after each step, reporting the first match or a 'no convergence' line. About 130 lines.

## Proof obligations to watch

- **index**: Candidate values and term indexes are ranged subtypes iterated by for loops over the arrays' own ranges, and the used-flag array is indexed only after a guard that the candidate is within the fixed limit.
- **termination**: A procedure Shares_Factor (or a function using a for loop over 2..Limit) tests common divisors with mod, avoiding a Euclid while loop whose termination a function could not prove, and all other loops are for loops.
- **other**: If no candidate is found within the fixed value limit, the generator sets an out Boolean failure flag and the program prints a visible 'limit exceeded' message instead of silently altering a term.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, Put without a newline, 'Image of scalars, string building and conditional expressions.

## External effects

- **console output** (allowed): Prints the five 10-term sequences and the convergence term as text lines.

Assessed on 2026-10-15 against page revision 415473 of the [task](https://rosettacode.org/wiki/EKG_sequence_convergence) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
