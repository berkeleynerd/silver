# Lucas-Carmichael numbers

**Candidate: proofs plausibly discharge automatically.** All data is bounded and fits in 64-bit integers with explicit guards, and no annotations are needed because recursion is replaced by an explicit stack, but proving no overflow in the lcm/product and root loops without invariants depends on careful guard placement.

Position 297 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Replace the recursive processLevel with an iterative depth-first search over fixed arrays of size 13 holding m, L, lo and the current candidate prime per level, run in procedures with while loops. Primality is by trial division up to the integer square root, and the extended-Euclid modular inverse and k-th root Newton loops are procedures using Long_Long_Integer subtypes bounded below 2^62 with guards before each multiply. Results are printed with Put_Line after converting integers to text, and the counts per decade are accumulated in a small array. About 230 lines.

## Proof obligations to watch

- **overflow**: Products m*p, lcm values and (n+1) approach 4e18 in 64-bit, so each multiplication is preceded by a divide-based guard (p <= B / m) and L is capped, with the search simply stopping at that visible outcome.
- **termination**: gcd, integer root and primality loops are while loops, so they live in procedures (no termination check) rather than functions, which forces out-parameter style code.
- **range**: Loop-carried values such as m, L, p and the explicit DFS stack depth are known only by type after the first iteration, so they need subtypes bounded to 2^62 and depth index guards before every use.
- **division**: Divisors p+1, L and m are loop-carried, so each division is guarded by an explicit nonzero test just before use.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the least number for each n and the cumulative counts as text lines.

Assessed on 2026-10-15 against page revision 403959 of the [task](https://rosettacode.org/wiki/Lucas-Carmichael_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
