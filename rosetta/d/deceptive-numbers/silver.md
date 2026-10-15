# Deceptive numbers

**Candidate: proofs likely to discharge automatically.** The first ten deceptive numbers (91, 259, 451, 481, 703, 1729, 2821, 2981, 3367, 3641) are small, so for loops over typed ranges with modular remainders keep all arithmetic bounded and need no invariants or variants.

Position 320 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Two functions on a bounded Candidate subtype (for example 2..20000): Is_Composite tests divisors with a for loop, and Is_Deceptive iterates r := (r*10+1) mod n for n-1 steps in a for loop to get R_(n-1) mod n and checks it is zero. Main runs a for loop over 49..20000 with a count < 10 guard, printing each hit via Integer'Image and incrementing a 0..10 counter, with an explicit stated search limit. About 45 lines.

## Proof obligations to watch

- **overflow**: The remainder r is a subtype bounded by the search limit and updated as (r*10+1) mod n, so the product stays far below Integer'Last given the typed range of r and n.
- **division**: Every mod uses n drawn from a for-loop range starting at 49 or a divisor from 2, so the divisor is statically nonzero.
- **range**: The match counter is a subtype 0..10 incremented only under an explicit count < 10 guard, so the increment cannot exceed its range.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, functions, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the first ten deceptive numbers, one per line, with Put_Line.

Assessed on 2026-10-15 against page revision 413568 of the [task](https://rosettacode.org/wiki/Deceptive_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
