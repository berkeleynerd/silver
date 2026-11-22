# Product of min and max prime factors

**Candidate: proofs likely to discharge automatically.** Everything is fixed-bound for loops over a 100-element array with component values constrained by a subtype, so index, range and overflow checks follow from types and loop bounds with no loop-carried unbounded values.

Position 164 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Two constant-size arrays of subtype 0 .. 100 indexed 1 .. 100 hold the smallest and largest prime factor, with entry 1 set to 1. An outer for loop over P in 2 .. 100 treats P as prime when its smallest-factor entry is still 0, then an inner for loop over multiples sets the smallest factor if unset and always overwrites the largest. A final for loop prints each product with Put, using a Put_Line of an empty string after every tenth value. About 45 lines.

## Proof obligations to watch

- **index**: Inner loop index P*K is bounded by iterating K over 1 .. 100/P, which provers handle as a nonlinear but small-range fact, with a guard (if P*K <= 100) before use as a fallback.
- **overflow**: Min*Max product is bounded by 100*100 because both array components have subtype 0 .. 100, so no overflow in Integer.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, integer division, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the 100 products, ten per line, to standard output.

Assessed on 2026-10-15 against page revision 413860 of the [task](https://rosettacode.org/wiki/Product_of_min_and_max_prime_factors) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
