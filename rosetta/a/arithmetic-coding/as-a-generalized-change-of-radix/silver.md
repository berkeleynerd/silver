# Arithmetic coding/As a generalized change of radix

**Candidate: proofs plausibly discharge automatically.** All checks follow from range-bounded digit arrays and for-loops, but the roughly 110-bit values force multi-step fixed-capacity big-number arithmetic carried through loops, so discharge depends on careful carry and capacity guards rather than being routine.

Position 1405 in the [progression](../../../progression.md#stage-26), in stage 26.

## Approach

Embed the four strings in fixed-length buffers, count symbol frequencies and cumulative frequencies in 256-entry Natural arrays indexed by Character position, and represent big values as a record holding a fixed array of decimal digits with in-place multiply-by-small, add, subtract, compare and divide-by-small procedures. Encoding follows the lower = lower*base + cum*pf, pf *= freq recurrence, then computes the radix power by repeated divide-by-10 and divides (upper-1) by 10^power; decoding multiplies back by 10^power and recovers each symbol by repeated subtraction against base^i, then compares with the original and prints the number via a bounded string buffer. About 260 lines.

## Proof obligations to watch

- **overflow**: The 24-character case needs about 110 bits, so values live in a fixed-capacity decimal digit array of about 40 digits, with each multiply-by-small and add keeping digit-plus-carry in a Long_Long_Integer range-bounded by subtypes and a leftover carry after the last digit rejecting with a visible outcome.
- **index**: Digit-array loops are for loops over the array's own range and frequency tables are indexed by a 0..255 Character position subtype, so indexes are bounded by types.
- **division**: Divisors are the symbol frequency (at least 1 for symbols present, guarded before dividing) and the radix constant 10, so they are guarded or static.
- **termination**: Big-number divide by a small value, subtraction-based quotient digits and the radix-power loop are written as for loops or as procedure while loops with a bounded counter, avoiding functions with while loops.
- **range**: Decoding must guard that the quotient digit and symbol lookup index stay within the table size, rejecting a malformed code instead of continuing.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, functions and big numbers.

## External effects

- **console output** (allowed): Prints each string, its encoded base-10 number, the radix exponent and a decode-verification result.

Assessed on 2026-10-15 against page revision 396415 of the [task](https://rosettacode.org/wiki/Arithmetic_coding/As_a_generalized_change_of_radix) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
