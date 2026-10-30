# Geometric algebra

**Candidate: proofs plausibly discharge automatically.** Everything is fixed-size integer array arithmetic in for loops with small-range coefficient types, so checks follow from bounds and guards, but chained-product coefficient growth and the xor index need careful range guards, hence plausible.

Position 1304 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Represent a multivector as a 32-element array of small-range integer coefficients indexed by basis bitmask, with e(n) setting coefficient 1 at index 2**n and the geometric product summing sign(i,j)*a(i)*b(j) into index i xor j using a bit-counting reordering sign. A deterministic LCG in a procedure supplies small random coefficients, and the program prints inner products e_i.e_j and the two sides of each of the four axioms, guarding every accumulated coefficient and rejecting with a visible message on overflow. About 170 lines.

## Proof obligations to watch

- **overflow**: Coefficient accumulation in the 32x32 product loops is loop-carried, so each term and running sum is computed in a wider integer type from small-range coefficient subtypes and checked against the coefficient range with a visible rejection outcome.
- **range**: Chained products (ab)c and a(bc) grow coefficients beyond a single product's bound, so the random coefficient range is kept tiny and each product result is guarded before it is stored in the narrow type.
- **index**: The product index is the XOR of two modular values below 32, which the prover must bound, so the index type is a 0..31 subtype reached through a guarded conversion.
- **floating point**: The program avoids floats by using exact integer coefficients and a small LCG for rand, which keeps the axiom comparisons exact and the checks integer-only.

## Language surface recorded by this assessment

Integers, integer division, modular types, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, procedures, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the orthonormality results and the two sides of each axiom check.

Assessed on 2026-10-15 against page revision 384768 of the [task](https://rosettacode.org/wiki/Geometric_algebra) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
