# Pierpont primes

**Candidate: proofs plausibly discharge automatically.** All values stay under about 30 million, so ranged integers and explicit guards on the candidate counter and array counts discharge every check, with loops placed in procedures to avoid termination checks; only the optional big-number part is skipped.

Position 256 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Two procedures use while loops: one tests whether a number is of the form 2^u*3^v by repeatedly dividing by 2 and 3, and one tests primality by trial division with a bounded subtype divisor. A main search loop walks the candidates under a subtype limit, tests x+1 and x-1 for smoothness, then primality, and stores hits in two 50-element arrays guarded by counts below 50. The arrays are then printed as ten lines of five or ten numbers each using image conversion and bounded string building. About 90 lines.

## Proof obligations to watch

- **overflow**: The candidate counter is a loop-carried value, so the loop guards it against a declared upper limit (above 30,233,087) before incrementing, and trial-division squares stay within a subtype capped near 6,000.
- **index**: Array stores happen only under an explicit count-below-50 guard, so the index is bounded by the condition just before the store without any invariant.
- **termination**: The while loops (smoothness test, trial division, candidate search) live in procedures with out parameters, which get no termination check, so no variant is needed.
- **range**: If the limit is reached before 50 primes are found the program must reject visibly rather than print a short list, which a guard after the loop covers.
- **other**: The optional 250th-prime part needs fixed-capacity big numbers with primality testing of numbers with hundreds of digits, which is left out as optional.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, procedures, for loops, while loops, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the two lists of 50 primes as decimal text lines.

Assessed on 2026-10-15 against page revision 412972 of the [task](https://rosettacode.org/wiki/Pierpont_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
