# Palindromic gapful numbers

**Candidate: proofs plausibly discharge automatically.** Every check follows from subtypes and guards placed before each operation, but the digit-reversal accumulator, bounded counters and manual number-to-text formatting need careful shape, and nothing requires an annotation.

Position 727 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Enumerate palindromes directly in increasing order by length (3 to 10 digits) and half-number, build each value from its half and a guarded reversal, test divisibility by 11 times the first digit, and append hits to a 9-by-1000 table of 64-bit integers indexed by leading digit until each row holds 1000 entries. Then print the three row ranges (1-20, 86-100, 991-1000) by converting each number to right-aligned decimal text in a fixed buffer and writing it with Put and Put_Line. About 130 lines.

## Proof obligations to watch

- **overflow**: Palindromes are built from a bounded half-number (subtype 1..99999) with a reversal accumulator guarded before each multiply-by-ten step, and the final value (at most 10 digits) fits easily in a 64-bit integer type.
- **index**: Counts per leading digit are a subtype 0..1000 and a store happens only after a guard that the count is below the capacity, while digit indexes are subtypes 1..9 so the 9-by-1000 table accesses are statically in range.
- **division**: The divisor is 11 times the first digit, a subtype 1..9, so it is statically nonzero and the mod check is routine.
- **length**: Row text is assembled in a fixed-size buffer with each right-aligned 11-wide column written at a computed offset from a digit-by-digit conversion, so offset guards must be explicit.
- **termination**: The enumeration over palindrome lengths and half-numbers uses for loops, and any while loop for digit extraction sits in a procedure, so no variant is required.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, procedures, 'Image of scalars, string building, string indexing and Put without a newline.

## External effects

- **console output** (allowed): The nine-column tables of the first 20, last 15 of 100 and last 10 of 1000 palindromic gapful numbers are printed as text lines.

Assessed on 2026-10-15 against page revision 413827 of the [task](https://rosettacode.org/wiki/Palindromic_gapful_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
