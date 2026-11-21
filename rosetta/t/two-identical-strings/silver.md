# Two identical strings

**Candidate: proofs likely to discharge automatically.** All loops are bounded for loops over constant ranges with small-typed carried values, and slice indices are guarded just before use, so no annotation is needed and the only gap is Silver's missing arrays, slices and integer-to-text support.

Position 1045 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Loop N over 1..999 in Main; for each N, fill a 10-character buffer with its binary digits via a reverse for loop using mod 2 and division on a copy bounded by a Natural subtype, then locate the first '1' with a for loop that records the position in a bounded index variable. If the digit count is even and the two half-slices are equal, print the decimal image and binary slice with Put_Line, so every index and length is guarded by a test just before use. About 35 lines.

## Proof obligations to watch

- **index**: Slice bounds First..First+Len/2-1 and First+Len/2..10 depend on a loop-found First, discharged by a guard that First is in 1..10 and Len is even and positive just before slicing.
- **length**: Concatenating the Integer image, a space and the slice has a bounded length because N is at most 999 and the slice at most 10 characters, within the output string's fixed size.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, 'Image of scalars, Boolean objects, conditional expressions, for loops and unconstrained arrays.

## External effects

- **console output** (allowed): Prints one line per matching integer with its decimal and binary forms.

Assessed on 2026-10-15 against page revision 413951 of the [task](https://rosettacode.org/wiki/Two_identical_strings) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
