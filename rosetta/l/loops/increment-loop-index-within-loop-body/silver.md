# Loops/Increment loop index within loop body

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded by a declared 64-bit range and explicit guards, and the only unbounded loop sits in a procedure, so no annotation is needed. The nonlinear product, loop-carried buffer position and index doubling need careful guards, so discharge depends on program shape.

Position 557 in the [progression](../../../progression.md#stage-12), in stage 12.

## Approach

Use a ranged 64-bit integer subtype for the index, a function Is_Prime that trial-divides with a for loop over 2..20_000_000 and exits when T*T exceeds the number, and a procedure with a while loop that increments the index, tests primality, prints the count and prime, and sets the index to index plus prime. Primes are converted to comma-grouped text by digit extraction with mod and div into a fixed-size String buffer, and a guard stops the search with a printed message if the index would exceed the 2*10**14 limit. About 80 lines.

## Proof obligations to watch

- **overflow**: The index doubling and T*T trial-division product are discharged by a 64-bit range type plus an explicit guard that stops with a visible message if the index exceeds 2*10**14 and by a divisor loop capped at 20,000,000.
- **index**: Comma formatting writes digits into a fixed 24-character buffer using a loop-carried position, so each write needs a guard on the position (or a for loop over the buffer's range) since no invariant can be given.
- **termination**: The unbounded main search loop is a while/exit loop inside a procedure, which gets no termination check, while Is_Prime uses a bounded for loop with exit so the function terminates automatically.
- **range**: The prime counter is bounded by the loop's exit at 42 so its increment is safe, but the prover only knows its type range, so the counter type must be a small ranged subtype with a guard before incrementing.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, string indexing, string building, 'Image of scalars, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): Prints 42 lines of prime count and comma-grouped prime via Put_Line.

Assessed on 2026-10-15 against page revision 415552 of the [task](https://rosettacode.org/wiki/Loops/Increment_loop_index_within_loop_body) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
