# Ascending primes

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed array bounds, ranged subtypes and guards placed before each push or multiplication, and all loops sit in a procedure so no variants are needed, though several loop-carried indices and values need careful guards.

Position 811 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Breadth-first generation of numbers with strictly ascending digits uses a fixed-capacity array queue of 511 candidates seeded with 1..9, where each popped value N spawns N*10+D for D greater than its last digit, guarded by the capacity and a 123456789 value limit. Each candidate is tested by trial division in a for loop over 2..11112 with exit when a divisor is found and the square is checked, and primes are printed with Put of the integer image separated by spaces, then a final line terminator. About 55 lines.

## Proof obligations to watch

- **overflow**: The candidate*10+digit step in the breadth-first generator is computed in a 64-bit range type and a guard (value at most 123456789) precedes storing it back into the narrower subtype, so the check follows from the guard.
- **index**: The queue array has fixed capacity 600 and a tail-below-capacity guard precedes each push, while the head index is checked against tail before each pop, since loop-carried indices are known only by type.
- **termination**: The generator and trial-division loops live in a procedure, which has no termination check, and trial division can instead be a for loop over 2..11112 with exit when.
- **overflow**: The trial-division square d*d is bounded by the loop range so it cannot overflow a 64-bit type, which is routine nonlinear arithmetic with bounded operands.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, Put without a newline and case statements.

## External effects

- **console output** (allowed): The 100 primes are printed to standard output.

Assessed on 2026-10-15 against page revision 413643 of the [task](https://rosettacode.org/wiki/Ascending_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
