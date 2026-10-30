# No prime sums

**Candidate: proofs plausibly discharge automatically.** All values for eight elements stay below about 70000 so a fixed sieve and a 256-entry subset-sum table suffice, and every check follows from range subtypes and guards before use, though the loop-carried table indices and sums need careful guarding. The ten-element stretch is optional and skipped since its sums reach tens of millions.

Position 268 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A Boolean composite sieve array up to about 200000 is built with while loops in a procedure. For each variant (any, odd, even), a procedure keeps a 256-entry table of subset sums and a count, searches upward from the previous element for a candidate whose sum with every table entry is composite and of the right parity, then doubles the table with the new element. Every sum is guarded against the sieve limit before indexing, and exceeding the limit or the table capacity prints a visible failure message. About 110 lines.

## Proof obligations to watch

- **index**: Sieve lookups of sum plus candidate are guarded by an explicit check against the sieve limit, and exceeding it produces a visible rejection outcome rather than a changed result.
- **overflow**: Subset sums are stored in a ranged subtype and each new sum is checked against the limit before storing, so the carried values stay bounded without an invariant.
- **termination**: The candidate search and sieve use while loops inside procedures, which get no termination check, and the candidate is capped by a guard that rejects when exceeded.
- **index**: The doubling subset-sum table (up to 256 entries) is indexed by a count that only a loop invariant would bound, so the program needs a guard before each write that falls to a visible failure outcome.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the three eight-element sequences as bracketed lists.

Assessed on 2026-10-15 against page revision 402576 of the [task](https://rosettacode.org/wiki/No_prime_sums) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
