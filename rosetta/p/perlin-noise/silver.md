# Perlin noise

**Candidate: proofs plausibly discharge automatically.** There are no loops, recursion or contracts needed, and the integer indexing follows from subtype ranges, so only the bounded float arithmetic and the float-to-integer floor conversion need careful range subtypes. The outlook is plausible rather than likely because floating-point proof and float formatting are the weaker areas of the provers and the library.

Position 1095 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

A constant 512-entry array of a 0..255 subtype holds the permutation table twice, with Fade, Lerp and Grad as plain functions on a range-bounded Long_Float subtype and Grad using a case statement on the hash masked to 0..15. Noise takes the floor of each coordinate through a guarded conversion, masks to 0..255, computes the eight corner hashes by array lookups and does the trilinear lerp with no loops. The main procedure calls Noise on (3.14, 42.0, 7.0) and prints the result with Put_Line. About 110 lines.

## Proof obligations to watch

- **floating point**: Fade, lerp and grad use 64-bit float arithmetic that discharges only because every coordinate is declared in a small range subtype and the fractional parts lie in 0.0 to 1.0, so no operation can overflow.
- **range**: Converting the floor of each coordinate to an integer and masking it to 0..255 needs the coordinate subtype bounded (for example -1000.0 to 1000.0) so the float-to-integer conversion cannot fail.
- **index**: Permutation lookups such as p(p(a)+b)+c+1 stay within a 512-entry table because every element is declared as 0..255 and the sums are at most 511, which follows from types alone.
- **other**: Printing the result to 15 decimals requires either a float image routine whose specification is admitted or scaling to an integer after a range guard, and the value 0.13691995878400012 is checked only at run time, not by proof.

## Language surface beyond today's Silver

Integers, ranged subtypes, floating point, arrays, functions, case statements, 'Image of scalars, floating-point images and Put without a newline.

## External effects

- **console output** (allowed): The program prints the noise value for (3.14, 42, 7) on one line.

Assessed on 2026-10-15 against page revision 414977 of the [task](https://rosettacode.org/wiki/Perlin_noise) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
