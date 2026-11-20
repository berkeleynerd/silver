# Find adjacent primes which differ by a square integer

**Candidate: proofs likely to discharge automatically.** All loops are for loops over static ranges and every loop-carried value is a ranged subtype or guarded, so index, range and overflow checks follow from types and guards without any invariant. The only non-routine items are the large fixed array and the nonlinear sieve index, both handled by bounds.

Position 122 in the [progression](../../progression.md#stage-5), in stage 5.

## Approach

A Boolean array indexed 0..1_000_000 is filled by a sieve of Eratosthenes using nested for loops with a guard on the product index, then a single for loop scans 2..999_999 remembering the previous prime in a variable of a ranged subtype. For each adjacent pair with a gap over 36, a for loop over k in 7..1000 tests whether k*k equals the gap, and matches are printed as three numbers per line using Integer'Image concatenation. About 45 lines.

## Proof obligations to watch

- **index**: The sieve multiple i*m is guarded by an explicit comparison against the array bound just before indexing, and the operands are small enough that the product cannot overflow.
- **stack**: A one-million-element Boolean sieve is a fixed-size object that depends on the environment having enough stack or static storage, which GNATprove does not check.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each qualifying prime pair and its difference as text lines.

Assessed on 2026-10-15 against page revision 415476 of the [task](https://rosettacode.org/wiki/Find_adjacent_primes_which_differ_by_a_square_integer) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
