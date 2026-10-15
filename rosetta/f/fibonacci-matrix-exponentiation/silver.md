# Fibonacci matrix-exponentiation

**Candidate: proofs plausibly discharge automatically.** Every check follows from small ranged limb types and bounded loops, but the truncated leading-digit arithmetic with exponent tracking and carry propagation needs careful guard placement, so discharge depends on program shape rather than annotations.

Position 755 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Represent the 2x2 Fibonacci matrix twice: once as exact residues mod 10^20 in five base-10^4 limbs for the last 20 digits, and once as truncated 40-digit mantissas with an explicit decimal exponent for the first 20 digits, avoiding full multi-million-digit numbers. Square-and-multiply runs over the fixed bits of n in a procedure with embedded n values, and results are formatted into a bounded String with zero padding and printed with Put_Line, skipping the optional 2^64 extra whose exact digits cannot fit any bounded buffer. About 220 lines.

## Proof obligations to watch

- **overflow**: Limb products and column sums inside multiplication loops are loop-carried, so each limb is a small ranged subtype (base 10^4) and sums are reduced with a guarded carry step each iteration so no wide accumulator is needed.
- **range**: The exponent of the truncated leading-digit mantissa grows through squarings (up to about 2 million digits for n=10^7), so it is declared with a range far above that bound and guarded before each addition.
- **index**: Limb-array indices in the shifted truncation and schoolbook product are computed values, so each is guarded just before use or taken from for loops over the array's own range.
- **termination**: The binary-exponent loop is a for loop over a fixed 64-bit width (or a while loop confined to a procedure), so no function needs a variant.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string building, 'Image of scalars, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the first and last 20 digits of each Fibonacci number, one line per n.

Assessed on 2026-10-15 against page revision 406439 of the [task](https://rosettacode.org/wiki/Fibonacci_matrix-exponentiation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
