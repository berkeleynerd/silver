# Quad-power prime seeds

**Candidate: proofs plausibly discharge automatically.** Every check follows from types, fixed array bounds and guards, but the roughly 70-bit primality test needs fixed-capacity big-number arithmetic carried through loops, so discharge depends on careful program shape rather than being routine.

Position 1388 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Search n upward in a procedure with a while loop capped by a documented limit, first filtering 2n+1 through a fixed-size sieve, then testing n^2+n+1, n^3+n+1 and n^4+n+1 for primality with a deterministic Miller-Rabin on a two-limb fixed-capacity unsigned number, with mulmod done by double-and-add over fixed bit counts. Found seeds go into a 50-element array and are printed ten per line using integer image text; the stretch part is omitted as optional. About 220 lines.

## Proof obligations to watch

- **overflow**: n^4+n+1 reaches about 7e20 for the fiftieth seed, beyond 64 bits, so powers and modular products use a two-limb fixed-capacity number whose limbs are bounded by their modular or ranged types and whose carries are guarded.
- **overflow**: Modular multiplication inside Miller-Rabin carries values through bit-by-bit loops with no invariant, so each step reduces the operand below the modulus with an explicit compare-and-subtract guard just before the next addition.
- **termination**: The unbounded search for seeds is a while loop inside a procedure, so it gets no termination check, and the candidate n is also capped by a documented limit with a visible stopping outcome.
- **division**: Any mod or division by a candidate or limb base is guarded by a nonzero test or uses a static nonzero constant.
- **index**: The sieve for 2n+1 and the limb arrays are indexed only by for-loop variables over their own range or by values guarded against the bound.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, modular types, Boolean objects, arrays, for loops, while loops, procedures, functions, big numbers, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the fifty seeds ten per line with Put_Line and Put.

Assessed on 2026-10-15 against page revision 413870 of the [task](https://rosettacode.org/wiki/Quad-power_prime_seeds) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
