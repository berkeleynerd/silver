# Wilson primes of order n

**Candidate: proofs plausibly discharge automatically.** Modular factorial arithmetic keeps every value inside bounded 64-bit ranged subtypes, so no big numbers or annotations are required and all loops terminate by construction. The outlook is plausible rather than likely because of the nonlinear bounded multiplications and the careful row-buffer construction.

Position 410 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Work with residues modulo p*p instead of big integers: for each odd candidate p up to 10999, test primality by a for-loop trial division, then for n in 1..11 compute (n-1)! and (p-n)! mod p*p in for loops with a mod after each multiply, and test whether (a*b - (-1)^n) mod p*p is zero. A matching p is written into column n of a fixed-width String row buffer using 'Image padding, and the row is printed with Put_Line after the fixed header. About 95 lines.

## Proof obligations to watch

- **overflow**: Factorials are kept as residues modulo p*p (at most 121,000,000) in range-typed 64-bit variables, so each product of two residues stays below 1.5e16 and the nonlinear multiply is bounded by types alone.
- **range**: The loop-carried accumulator is reduced with mod after every multiply and has a ranged subtype, so assignments discharge from the type range, though the provers must handle the nonlinear bound.
- **division**: The modulus p*p is declared in a subtype with lower bound 4, so mod never divides by zero.
- **length**: Each row is built in a fixed 55-character buffer with five-wide columns computed from n, and every image is guarded to fit in five characters before being copied in.
- **termination**: All loops are for loops or sit in the main procedure, with primality by trial division over a for loop, so no variant is needed.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the header and one table row per prime that is a Wilson prime for some order.

Assessed on 2026-10-15 against page revision 413964 of the [task](https://rosettacode.org/wiki/Wilson_primes_of_order_n) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
