# Repunit primes

**Candidate: proofs plausibly discharge automatically.** The task needs no recursion, annotations or unavailable effects, only console output and fixed-capacity big-number arithmetic of up to about 4000 bits, which is loop-heavy but expressible with range-bounded limbs and for loops. The proof burden lies in carry and index checks across many nested big-number loops, so it is plausible but not routine.

Position 1402 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

A sieve of Eratosthenes over a constant array yields the 168 prime digit counts up to 1000, and for each base 2..16 and each prime count p the repunit (b^p-1)/(b-1) is built in a fixed-capacity limb array by repeated multiply-by-base-and-add-one in a for loop. A fixed-base Miller-Rabin test written with limb-array add, subtract, compare and shift-and-add modular multiplication (no division) decides primality, after trial division by small primes, and each prime p is appended to a bounded output line printed with Put and Put_Line. Every limb operation is guarded by the declared capacity and uses ranged limb subtypes so carries stay in range. About 320 lines.

## Proof obligations to watch

- **overflow**: Limb additions, shifts and carries inside big-number loops are discharged by keeping limbs in a small ranged subtype (for example below 2**16) so that carry sums fit in Integer from type ranges alone, but each loop-carried carry needs a clamping guard.
- **index**: Fixed-capacity limb arrays are indexed only by for-loop variables over the array range or by guarded computed positions, with a visible rejection outcome when a value would exceed the capacity.
- **range**: The repunit for base 16 and 1000 digits needs 4000 bits, so the capacity must be sized for that documented limit and any larger candidate must be rejected explicitly rather than truncated.
- **termination**: Modular exponentiation, trial division and the sieve use for loops, and the only while loops (digit-count search and compare/subtract normalisation) sit in procedures, which get no termination check.
- **other**: Primality is decided by Miller-Rabin with fixed bases (probabilistic like the existing solution), and the work of roughly 168 primes times 15 bases of 4000-bit modular exponentiations is large though not a proof matter.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions, big numbers, 'Image of scalars, string building, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints, for each base 2 through 16, the list of prime digit counts up to the limit, one line per base.

Assessed on 2026-10-15 against page revision 413881 of the [task](https://rosettacode.org/wiki/Repunit_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
