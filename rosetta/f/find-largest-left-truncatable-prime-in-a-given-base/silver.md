# Find largest left truncatable prime in a given base

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic in procedures with guards before each product and store, so checks follow from types and guards, but several loop-carried values (place value, counts, divisor) need careful guarding and the task's full table needs big numbers beyond the documented cap.

Position 289 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Values are held in a bounded 62-bit integer subtype with the base and digit in small ranged subtypes, and each level's candidate primes are stored in two fixed-capacity arrays swapped by copying. A procedure Is_Prime uses trial division in a while loop with a divisor cap so the square cannot overflow, then a for loop over bases 3 to 17 extends each candidate by every leading digit 1..base-1, guarding value and capacity before every product and store. Results for bases whose answer fits the cap are printed, others print an explicit exceeds-limit line. About 130 lines.

## Proof obligations to watch

- **overflow**: Prepending a digit computes d*place+n, and trial-division computes q*q; each is preceded by a guard against a documented 62-bit value cap and a 2^31 divisor cap so the products stay in range.
- **index**: Candidate lists are fixed-capacity arrays whose append index is checked against capacity before each store, with a visible 'capacity exceeded' outcome that stops that base.
- **range**: Loop-carried place value and counts are declared with bounded subtypes and guarded before multiplying by the base, since without invariants only type ranges are known.
- **other**: Bases whose answers exceed the 64-bit cap (for example 10 and 12) are reported as exceeding the documented limit instead of computed, because big-number arithmetic with modular exponentiation would add many loop-carried guards.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): One line per base giving the largest left truncatable prime.

Assessed on 2026-10-15 against page revision 415244 of the [task](https://rosettacode.org/wiki/Find_largest_left_truncatable_prime_in_a_given_base) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
