# Verhoeff algorithm

**Candidate: proofs likely to discharge automatically.** All checks follow from the 0..9 subtype for the checksum, the string's own index range, a digit guard on each character, and a fixed maximum length, with no while loops, recursion or annotations needed.

Position 995 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed the d, inv and p tables as constant arrays of a 0..9 digit subtype, and write a procedure that walks the digit string from the right with a for loop, rejecting non-digit characters, updating the 0..9 checksum through table lookups and optionally printing a trace line per step. A check-digit procedure appends a zero and returns inv of the checksum, a validate function tests that the checksum is 0, and the main procedure runs the three embedded numbers with both the true and the substituted 9 check digit, tracing only the first two. About 150 lines.

## Proof obligations to watch

- **range**: Converting each character to a digit is guarded by a digit-range test that rejects non-digit input visibly, and the accumulator is a 0..9 subtype so table indexes are always in range.
- **index**: The permutation row is computed as position mod 8 and the loop runs over the string's own range, so every index check follows from types and loop bounds.
- **length**: Appending the check digit or building trace lines in fixed buffers needs a documented maximum input length with a visible rejection of longer input.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, unconstrained arrays, string indexing, string building, 'Image of scalars, for loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints check digits, validation results and the digit-by-digit trace tables.

Assessed on 2026-10-15 against page revision 413959 of the [task](https://rosettacode.org/wiki/Verhoeff_algorithm) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
