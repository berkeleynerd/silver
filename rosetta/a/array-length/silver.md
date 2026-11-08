# Array length

**Candidate: proofs likely to discharge automatically.** The array length is a static attribute of a constant array of fixed-size strings, and printing it needs only a bounded image conversion, so every check follows from declarations.

Position 89 in the [progression](../../progression.md#stage-4), in stage 4.

## Approach

Declare a constant one-dimensional array of two fixed-length Strings, which needs a common element length, so use a bounded record or two equal-padded strings, e.g. Fruit_Name subtype String (1 .. 6) with apple padded to 6 characters. Print the array's 'Length through Natural'Image concatenated onto a fixed label with Put_Line. All indices and lengths are static, so no loop or guard is needed. About 22 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the element count of the array to standard output.

Assessed on 2026-10-15 against page revision 412655 of the [task](https://rosettacode.org/wiki/Array_length) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
