# Harshad or Niven series

**Candidate: proofs plausibly discharge automatically.** All arithmetic is small bounded integers with mod and division, and the checks on loop-carried values (digit sum, candidate, divisor) can each be handled by type bounds and a guard just before use, with no annotations required.

Position 228 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A procedure Digit_Sum (in Natural bounded subtype, out sum) loops over a fixed six digit positions with a for loop, taking mod 10 and dividing by 10, and a procedure Next_Harshad advances a bounded candidate with a while loop until candidate mod digit sum = 0, guarding sum > 0. Main calls it 20 times printing each value with Put and 'Image, then starts from 1001 for the first Harshad number above 1000 and prints it with Put_Line. About 60 lines.

## Proof obligations to watch

- **overflow**: The loop-carried digit sum is only known by its type, so each addition is guarded or the sum is typed wide enough that adding up to six digits of 9 cannot exceed it.
- **division**: The divisor (digit sum) is loop-carried, so an explicit guard that it is positive precedes the mod, which is harmless because any positive candidate has a positive digit sum.
- **range**: The candidate counter is incremented in a while loop, so it is kept in a bounded subtype with an explicit loop condition (candidate below a documented limit such as 100000) that leads to a visible rejection outcome if reached.
- **termination**: The search loops live in procedures, which get no termination check, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, while loops, procedures, 'Image of scalars, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): Prints the first 20 Harshad numbers and the first one above 1000 to standard output.

Assessed on 2026-10-15 against page revision 415514 of the [task](https://rosettacode.org/wiki/Harshad_or_Niven_series) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
