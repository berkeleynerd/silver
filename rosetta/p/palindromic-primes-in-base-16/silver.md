# Palindromic primes in base 16

**Candidate: proofs likely to discharge automatically.** All values are tiny bounded integers below 500, so every check follows from declared ranges and for-loop bounds with no loop-carried values needing invariants.

Position 513 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

A for loop runs N over 2..499; primality is tested by trial division in a for loop over 2..22 using mod. Hex digits are extracted into a fixed 3-element array of 0..15 by repeated division in a for loop, leading zeros are skipped by a bounded scan, and the palindrome test compares symmetric entries; matches are printed via a constant 16-character lookup string using Put and Put_Line. About 50 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, functions, Put without a newline, string indexing and characters.

## External effects

- **console output** (allowed): Prints the palindromic primes and optionally a count.

Assessed on 2026-10-15 against page revision 413828 of the [task](https://rosettacode.org/wiki/Palindromic_primes_in_base_16) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
