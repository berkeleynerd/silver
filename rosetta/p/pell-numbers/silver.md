# Pell numbers

**Candidate: proofs plausibly discharge automatically.** Everything except the Pell primes fits in bounded 64-bit integer loops, but the 10th Pell prime needs about 116-bit primality testing, which forces big-number modular arithmetic whose checks are bounded by types and guards without annotations, so success depends on careful program shape.

Position 1413 in the [progression](../../progression.md#stage-26), in stage 26.

## Approach

Compute Pell and Pell-Lucas numbers for indices 0..89 in a fixed-capacity big-number array type, using the recurrence in a for loop in a procedure; the approximations (first 10), NSW numbers and near-isosceles triples (first 10, hypotenuses up to P(21)) stay within 64-bit ranged integers, with decimal expansions obtained by integer long division. Pell primes are found by testing only prime indices up to 89 with a deterministic Miller-Rabin written over the big-number type with a fixed set of witnesses, and printing is done with Put_Line over computed-length strings built in bounded buffers. About 330 lines.

## Proof obligations to watch

- **overflow**: The 10th Pell prime P(89) is about 4e34, beyond 64 bits, so the program needs a fixed-capacity big-number type whose limb additions, doublings and carries are bounded by limb-sized types and guards.
- **overflow**: Primality testing of those numbers needs a modular multiplication and exponentiation on big numbers, with nonlinear limb products that discharge only if each limb is a bounded subtype sized so a product plus carry fits in 64 bits.
- **index**: Big-number loops carry limb indexes and carries across iterations without invariants, so each access must be a for-loop index over the array's own range or be guarded just before use.
- **termination**: Shift-and-subtract division and the Miller-Rabin loops are while loops that must live in procedures, which get no termination check, and any helper that cannot be a for loop must not be a function.
- **range**: Decimal digits of the approximations are produced by integer long division with a fixed digit count, and the 20 or so Pell values used there stay within Long_Long_Integer by declared bounds on the term count.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions, big numbers, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The program prints the sequences, approximations, primes, indices, NSW numbers and triples to standard output.

Assessed on 2026-10-15 against page revision 412147 of the [task](https://rosettacode.org/wiki/Pell_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
