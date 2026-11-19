# Quadrat special primes

**Candidate: proofs likely to discharge automatically.** Everything is small integer arithmetic on range-bounded values with explicit guards before each index and addition, so proofs should discharge without invariants. The only moderate effort is formatting the numbers into a bounded output buffer.

Position 357 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Build a Boolean prime sieve array over 0..32000 with for loops and a guarded inner marking loop (or use a bounded for-loop trial division function). A procedure walks q starting at 2, tries j from 1 upward with p = q + j*j guarded against the array bound, takes the first prime p as the next q, and appends each q below 16000 to a bounded line buffer printed with Put_Line, seven per line. If no p is found within the bound, it prints a specified failure message instead. About 70 lines.

## Proof obligations to watch

- **overflow**: The candidate p = q + j*j stays far below Integer'Last because q and j are range-bounded subtypes (q at most 16000, j at most 200), and the search stops with a visible message if p exceeds the sieve bound.
- **index**: Sieve and marking indexes are guarded by an explicit comparison against the array bound just before use, so no loop invariant is needed.
- **termination**: All while loops live in procedures, which get no termination check, and the Is_Prime function uses a bounded for loop over divisors.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the heading and the list of special primes to standard output.

Assessed on 2026-10-15 against page revision 387194 of the [task](https://rosettacode.org/wiki/Quadrat_special_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
