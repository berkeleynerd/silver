# Fast Fourier transform

**Candidate: proofs plausibly discharge automatically.** Iterative FFT over a fixed 8-point embedded input with constant twiddles uses only for loops and bounded float types, so checks follow from per-stage type ranges, though floating-point range reasoning and float-to-text formatting need careful shape. No annotations or recursion are required, and no Oracle rule is broken.

Position 1089 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

The program embeds the 8-point example as a complex record array of bounded floats (real and imaginary parts), reorders it through a constant bit-reversal table, and runs an iterative radix-2 butterfly with three for-loop stages using constant twiddle factors (cos and sin of multiples of pi/4) in place of recursion. Each stage writes into an array of a wider bounded float subtype so no check depends on an invariant, and results are printed as fixed-width decimal text in a procedure. About 110 lines.

## Proof obligations to watch

- **floating point**: Butterfly additions and twiddle multiplications on loop-carried floats discharge only if each stage's array uses its own bounded float subtype with a doubling margin, which also keeps results finite.
- **index**: Indexes come from for loops over the array range and a constant bit-reversal table of in-range values, and partner indexes are guarded before use.
- **overflow**: Index arithmetic for butterfly positions at each stage uses small ranged integer types fixed for N = 8, so no wraparound is possible.
- **length**: Formatted number text is built in fixed-size buffers sized for the bounded value range, so concatenation lengths are statically within limits.

## Language surface beyond today's Silver

Floating point, floating-point images, ranged subtypes, arrays, records, for loops, procedures, integers, integer division, 'Image of scalars, string building, Put without a newline, functions and Boolean objects.

## External effects

- **console output** (allowed): The input sequence and its transform are printed as text lines.

Assessed on 2026-10-15 against page revision 414944 of the [task](https://rosettacode.org/wiki/Fast_Fourier_transform) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
