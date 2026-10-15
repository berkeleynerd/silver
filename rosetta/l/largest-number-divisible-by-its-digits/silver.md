# Largest number divisible by its digits

**Candidate: proofs likely to discharge automatically.** Every check follows from a bounded for loop, ranged subtypes, a 0..9 array indexed by mod 10 and an explicit nonzero-digit guard before each mod, so no annotation is needed and no while loop or function loop termination is involved. The hexadecimal stretch goal is optional and omitted.

Position 511 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Search candidates in descending order from 9876432 in steps of 504 (a multiple of 7*8*9, so divisibility by 2,3,4,6,7,8,9 is guaranteed and the search remains a real search) using a bounded for loop over Step in 0..19600, and keep the first candidate that passes a digit check. The check is a nested procedure that loops a fixed 7 times over the digits via T mod 10 and T / 10 on a ranged copy, marking digits in a Boolean array Seen(0..9), rejecting a zero digit, a repeated digit or a nondivisible digit with explicit guards before each division. The result is held in a ranged Best variable with a Found flag, and printed as a trimmed Integer'Image slice with Put_Line. About 45 lines.

## Proof obligations to watch

- **overflow**: The candidate 9876432 - 504*Step is computed from a Step subtype bounded to 0..19600, so the product and difference stay within the declared candidate range and the provers handle this constant-bounded multiplication.
- **division**: Both N mod Digit and the digit extraction guard Digit /= 0 explicitly in the preceding branch (zero digit rejects the candidate), so the divisor is provably nonzero.
- **index**: The Seen array is indexed 0..9 by a value computed as T mod 10, whose range is statically 0..9, so every index check follows from the type bounds.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, 'Image of scalars and string indexing.

## External effects

- **console output** (allowed): The program prints the single result number (9867312) with Put_Line.

Assessed on 2026-10-15 against page revision 413755 of the [task](https://rosettacode.org/wiki/Largest_number_divisible_by_its_digits) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
