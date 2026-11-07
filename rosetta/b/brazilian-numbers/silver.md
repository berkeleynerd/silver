# Brazilian numbers

**Candidate: proofs plausibly discharge automatically.** All loops are bounded by declared ranges and every arithmetic value fits a small range subtype, so proofs should discharge with careful guards and without any invariants, provided digit-peeling and trial division are written as for loops or in procedures.

Position 375 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Use a bounded subtype for candidates, procedures Same_Digits and Is_Brazilian returning Boolean via out parameters, with for loops over bases 2 .. N-2 and a for loop over a fixed maximum digit count to peel digits by mod and /. Three passes (all, odd, prime) each scan candidates upward under a fixed upper bound, printing numbers via 'Image into bounded buffers with Put_Line, with primality tested by for-loop trial division up to a fixed small bound. About 70 lines.

## Proof obligations to watch

- **termination**: The digit-peeling loop and trial-division prime test are while loops so they live in procedures (or become for loops over a bounded digit count), since a function would need a variant.
- **overflow**: Numbers are held in a declared range subtype (e.g. 1 .. 10000) and the divisor loop variable is bounded by for-loops, so d*d and n+2 are guarded by range checks before use.
- **range**: The search for the next candidate is bounded by a fixed maximum (the 20th prime Brazilian is 757) and exits with a visible reject if the bound is reached, so counters and n+1 stay in type range.
- **index**: Result storage is a fixed array of 20 entries indexed by a counter guarded with Count < 20 before each store.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints three lines of 20 numbers each.

Assessed on 2026-10-15 against page revision 413464 of the [task](https://rosettacode.org/wiki/Brazilian_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
