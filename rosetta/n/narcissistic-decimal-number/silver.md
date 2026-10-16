# Narcissistic decimal number

**Candidate: proofs plausibly discharge automatically.** Every operation is bounded by types and explicit saturation or limit guards on loop-carried values, so no annotation is needed, but the accumulators and the unbounded-looking search loop need careful shaping.

Position 374 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

A procedure loops over candidates from 0 up to a documented limit of 10_000_000 while fewer than 25 are found. For each candidate, a for loop of at most 8 steps extracts digits by division and mod to count the digits, and a second for loop sums each digit raised to that count by repeated multiplication, with saturating guards. Matches are stored in a 25-element array or printed immediately via Image, and the program reports a visible failure if the limit is reached before 25 are found. About 55 lines.

## Proof obligations to watch

- **overflow**: The digit-power sum and the power product are loop-carried, so each is held in a 64-bit type and saturated by a guard at a bound above any candidate (for example 100_000_000) so the additions cannot overflow, which does not change the equality result.
- **termination**: The search loop is a while loop, so it lives in a procedure with an explicit upper limit of 10_000_000 candidates, and the digit loops are for loops that terminate by themselves.
- **range**: The candidate counter increments in a loop, so an explicit guard against the limit before incrementing keeps it inside its subtype, with a visible failure message if the limit is reached before 25 are found.
- **index**: The results array has capacity 25 and storing is guarded by Count < 25 just before the write, which the prover can see locally.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, functions, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the 25 numbers, one per line or space separated.

Assessed on 2026-10-15 against page revision 413511 of the [task](https://rosettacode.org/wiki/Narcissistic_decimal_number) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
