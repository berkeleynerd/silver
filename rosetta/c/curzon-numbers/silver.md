# Curzon numbers

**Candidate: proofs likely to discharge automatically.** All arithmetic is bounded by small integer subtypes (moduli at most about 10^6, products under 10^12) and every loop is a for loop with static bounds, so every check follows from types and guards without annotations. Output needs only Put and 'Image formatting.

Position 348 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Use a function Is_Curzon(K, N) that computes K**N mod (K*N+1) by square-and-multiply over 17 fixed bit iterations with bounded subtypes, then tests whether (result + 1) mod M = 0. A procedure loops over the bases 2, 4, 6, 8 and 10, and for each base a for loop over N in 1..100000 counts hits (count held in 0..1000), prints the first 50 in rows of ten using 'Image padding, and records the 1000th with exit once reached. If the cap is reached first, it prints a specified failure line. About 70 lines.

## Proof obligations to watch

- **overflow**: Products of residues stay below 10^12 because residues are held in a subtype bounded by 1,000,001, so Long_Long_Integer arithmetic cannot overflow.
- **termination**: Modular exponentiation uses a fixed 17-iteration for loop over the exponent bits instead of a while loop, so the function needs no variant.
- **range**: The search is capped at N = 100000 by a for loop with an exit when the count reaches 1000, and a base that fails to reach 1000 before the cap yields an explicit failure message rather than a silent change.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, functions, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 50-number tables per base and the 1000th Curzon number to standard output.

Assessed on 2026-10-15 against page revision 414815 of the [task](https://rosettacode.org/wiki/Curzon_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
