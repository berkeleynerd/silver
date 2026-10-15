# Sieve of Eratosthenes

**Candidate: proofs likely to discharge automatically.** All loops are for loops over static or computed ranges, so no loop-carried value needs an invariant, and the only nontrivial checks are the index and overflow of K * Base, which the Limit / Base loop bound makes dischargeable. The fixed limit is an allowed documented resource bound.

Position 125 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Embed a fixed Limit constant (for example 100) and an array Prime of Boolean indexed 2 .. Limit, all initialised True by an aggregate. An outer for loop runs Base over 2 .. a constant square-root bound; if Prime (Base), an inner for loop runs K over Base .. Limit / Base and marks Prime (K * Base) False, then a final for loop prints each index still True with Put_Line of its Integer'Image. About 30 lines.

## Proof obligations to watch

- **overflow**: The product K * Base in the inner loop is nonlinear, but K is bounded by Limit / Base so the product stays at most Limit, which provers handle with division reasoning and small subtype ranges.
- **index**: Indexing Prime (K * Base) needs K * Base within 2 .. Limit, which follows from the for-loop bounds Base .. Limit / Base and Base >= 2.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each prime found, one per line, with Put_Line.

Assessed on 2026-10-15 against page revision 415491 of the [task](https://rosettacode.org/wiki/Sieve_of_Eratosthenes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
