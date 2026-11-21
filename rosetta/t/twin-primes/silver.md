# Twin primes

**Candidate: proofs plausibly discharge automatically.** Sieve and count loops index a fixed array by for-loop ranges with guards, and parsing is the only loop-carried arithmetic, so no annotations are needed; the nonlinear multiple indexing is the main prover risk.

Position 1345 in the [progression](../../progression.md#stage-23), in stage 23.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Parse the first argument into a Natural bounded by a documented maximum (for example 1_000_000), rejecting empty, non-digit or too-large input with a visible Reject outcome, then fill a fixed-capacity Boolean sieve array with for loops and a guard on I*I <= Limit. Finally count indices P in 2..Limit-3 where P and P+2 are both prime (so both are under the limit) with a for loop, and print the count with Integer'Image text. The extension (10^7 and 10^9 and timing) is optional and omitted. About 70 lines.

## Proof obligations to watch

- **overflow**: Parsing the decimal argument accumulates a value in a loop, discharged by a digit-count guard and a limit check before each multiply-add on a bounded subtype.
- **index**: Sieve multiples J*I are computed in a loop with loop-carried values, discharged by a for loop over J in 2..Limit/I so the product is bounded, though nonlinear reasoning is needed.
- **range**: The count is a Natural bounded by the fixed sieve capacity, so accumulating it in a for loop stays within its type.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, 'Image of scalars, text parsing, for loops, while loops, procedures, functions, Put without a newline and exit status.

## External effects

- **arguments** (allowed): The user-specified search size is read from the first command-line argument.
- **console output** (allowed): The twin prime pair count is printed as a line of text.
- **exit status** (allowed): Rejecting an invalid or out-of-range search size should be reflected in the exit status.

Assessed on 2026-10-15 against page revision 413099 of the [task](https://rosettacode.org/wiki/Twin_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
