# Minimum positive multiple in base 10 using only 0 and 1

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged remainder types, fixed array capacities and explicit guards, and the BFS needs no variant because it runs in a procedure, but the carried queue and chain indexes make the program shape matter.

Position 467 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Embed the required n values in a constant array and loop over them, calling a procedure that does breadth-first search over remainders mod n, using fixed-size arrays for the queue, visited flags, parent remainder and appended digit (digit 1 first, then 0, so the first hit on remainder 0 is the minimum). The digits are recovered by walking the parent chain backwards into a bounded String buffer, guarded by capacity, then printed with n via concatenation and Integer'Image. All loops with loop-carried values are in procedures and each carried index is range-typed or guarded just before use. About 110 lines.

## Proof obligations to watch

- **index**: The BFS queue tail is guarded against the array capacity before each enqueue, and the parent-chain walk uses indexes typed to the remainder range, so no invariant is needed.
- **overflow**: The remainder update (r*10+d) mod n uses a ranged remainder subtype bounded by the largest n (about 5000), so the intermediate product fits easily in Integer.
- **division**: Every mod by n is preceded by a guard n >= 1, which the loop over the embedded list of n values satisfies by type.
- **length**: Digit count is bounded by the number of distinct remainders (at most n), so a fixed 5000-character buffer is guarded with an explicit capacity check before each digit is written and overflow gives a visible rejection line.
- **termination**: The BFS while loop and the chain-walk loop live in procedures, which get no termination check.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, for loops, while loops, procedures, string building and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each n with its B10 value, one line per n.

Assessed on 2026-10-15 against page revision 413789 of the [task](https://rosettacode.org/wiki/Minimum_positive_multiple_in_base_10_using_only_0_and_1) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
