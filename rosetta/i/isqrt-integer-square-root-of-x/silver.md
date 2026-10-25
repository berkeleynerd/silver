# Isqrt (integer square root) of X

**Candidate: proofs plausibly discharge automatically.** The algorithm uses only integer arithmetic that bounded subtypes and guards can keep in range, and the 64-bit limit is explicitly allowed by the task (show what you can), but the 7**N values up to 7**73 would need fixed-capacity big numbers to be fully faithful.

Position 270 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Use a bounded 64-bit integer subtype and a procedure Isqrt(X, Result) implementing the quadratic-residue algorithm with a for loop that grows q by 4 under a guard, then a for loop that shifts down and updates z and r. Print the 0..65 table in three rows via 'Image, then loop N over odd values 1..21 computing 7**N by guarded repeated multiplication and printing it and its Isqrt with commas inserted into a fixed buffer built from digit extraction by div and mod 10. About 110 lines.

## Proof obligations to watch

- **overflow**: The loop-carried q, r and z values have no invariant, so they get bounded subtypes and an explicit guard (q at most 4**29) before q*4, with x limited to 7**21 which is below 2**60.
- **range**: The 7**N value is built by repeated multiplication by 49 under a guard against exceeding the Int64 limit, which restricts output to N up to 21 as the task permits for smaller-integer languages.
- **index**: The comma-grouped output is built into a fixed 32-character buffer whose write positions must be guarded against underflow below the first index.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the horizontal table for 0..65 and the vertical table of odd powers of 7 with comma-grouped numbers.

Assessed on 2026-10-15 against page revision 414273 of the [task](https://rosettacode.org/wiki/Isqrt_%28integer_square_root%29_of_X) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
