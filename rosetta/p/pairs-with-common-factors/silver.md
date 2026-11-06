# Pairs with common factors

**Candidate: proofs plausibly discharge automatically.** The totient-sieve formula needs only bounded arrays, for loops and small integer arithmetic, so no annotation is needed, but the loop-carried sum and number formatting require guards and careful shaping.

Position 170 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Compute phi(1..1000) with a sieve in a fixed array, using nested for loops over primes and their multiples (a prime is an index whose phi is still unchanged). Then run a prefix sum of phi with a bounded-accumulator guard and compute a(n) = n(n-1)/2 + 1 - sum into an array of 1000 terms, subtyped to a safe range. Print the first one hundred terms ten per line via bounded string building with Image, then the 1000th term; the ten-thousandth and larger stretch terms are omitted as optional. About 70 lines.

## Proof obligations to watch

- **overflow**: The running totient sum is loop-carried and known only by its type, so each addition is guarded against an explicit cap that is visibly rejected (never silently clamped), and the cap is far above the true maximum of about 304000.
- **range**: The sieve step phi(m) - phi(m)/p stays within a declared 0..1000 subtype because the operands are bounded and the divisor is at least 2, which is a simple linear bound for the provers.
- **index**: All array indexes come from for loops over the array's own range, and the sieve's multiples are stepped through by a for loop over a quotient range, so no computed index is loop-carried.
- **length**: Number formatting into fixed-width buffers needs each integer's text to be guaranteed to fit its field, which follows from the bounded value subtype but takes careful shape.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first one hundred terms in rows of ten and the one thousandth term.

Assessed on 2026-10-15 against page revision 412954 of the [task](https://rosettacode.org/wiki/Pairs_with_common_factors) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
