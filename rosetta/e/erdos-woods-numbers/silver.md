# Erdős–Woods numbers

**Candidate: proofs plausibly discharge automatically.** Every check follows from subtype bounds and guards before mod, and loops sit in procedures so no variants are needed, but only the early terms fit a 64-bit bounded search, so the full 20 terms would need a big-number library.

Position 239 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Use a procedure Gcd with a while loop on subtype-bounded 64-bit integers, and a procedure Check_K that loops a over a bounded range and i over 1..k-1 with a for loop, skipping a when gcd(a, a+k) is 1 and setting a Found flag via explicit exit. The main loop walks even k, counts results up to 20 or a documented k limit, and prints each with Put_Line using 'Image concatenation; if the a limit is exhausted for a k, it moves on visibly, so only results found within the limit are printed. About 75 lines.

## Proof obligations to watch

- **overflow**: Candidate a is a subtype bounded by a documented search limit well below the 64-bit maximum, so a + k and the gcd operands cannot overflow.
- **division**: The Euclid loop in a procedure tests the divisor is nonzero in the while condition before each mod.
- **termination**: Gcd and the search are while loops inside procedures, which get no termination check, whereas making gcd a function would require a variant that Silver authors cannot write.
- **range**: Loop-carried gcd values and the found-count are kept within their subtypes by the loop guards, since without invariants only type ranges are known after the first iteration.
- **other**: Within the fixed limit on a, later terms (a exceeds 64 bits for the 20th) are not found, so the program reports as many as the bounded range allows, which the task explicitly permits for languages without arbitrary precision.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each Erdős–Woods number k with its smallest a, one line per result.

Assessed on 2026-10-15 against page revision 414185 of the [task](https://rosettacode.org/wiki/Erd%C5%91s%E2%80%93Woods_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
