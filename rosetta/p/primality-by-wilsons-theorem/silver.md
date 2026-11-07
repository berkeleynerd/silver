# Primality by Wilson's theorem

**Candidate: proofs likely to discharge automatically.** Every check follows from a subtype bound of 10**9 on the operands (so fact * i stays below 64-bit range), a for loop, and an n >= 2 guard before rem, so no annotation is needed.

Position 509 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Declare a ranged subtype 0 .. 10**9 and a Boolean Is_Prime function that returns False for n < 2, otherwise runs a for loop i in 2 .. n-1 keeping fact := (fact * i) rem n and finally compares fact = n - 1. Main loops num over 1 .. 499 with a for loop, and for each prime builds a right-aligned width-6 text from 'Image into a bounded line buffer, emitting a line after every 12 primes. About 45 lines.

## Proof obligations to watch

- **overflow**: The product fact * i is bounded by 10**18 because both operands are subtypes capped at 10**9, so it fits Long_Long_Integer and the overflow check discharges from types alone.
- **range**: The rem result must satisfy the subtype bound, which holds since it is less than n and n is at most 10**9, though the prover must infer this nonlinear fact.
- **division**: The rem by n is preceded by an explicit n < 2 early return so n is at least 2.
- **index**: The line buffer writes are guarded by a column counter that is flushed every 12 entries, so each write is within the fixed buffer bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions, 'Image of scalars, string building, string indexing, arrays and Put without a newline.

## External effects

- **console output** (allowed): Prints the primes below 500 to standard output, twelve per row.

Assessed on 2026-10-15 against page revision 413853 of the [task](https://rosettacode.org/wiki/Primality_by_Wilson's_theorem) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
