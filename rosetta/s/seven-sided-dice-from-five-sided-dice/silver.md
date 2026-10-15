# Seven-sided dice from five-sided dice

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic with array indices derived from guarded, range-typed values, and the only unbounded loop is a while loop in a procedure, so no annotation is needed. The one careful point is the loop-carried counters and the LCG state needing type-range or guard-based overflow safety.

Position 241 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A deterministic LCG with a declared-range state yields dice5 as a procedure that updates the state and returns 1..5; dice7 is a procedure that rolls twice to form N in 0..24, loops while N is at least 21, and returns N/3+1. The main procedure runs a for loop of 1,000,000 calls tallying into a 7-element array of bounded counters, then prints each bin with Put_Line and checks every bin against an integer tolerance band around 1,000,000/7, printing Passed or Failed. About 70 lines.

## Proof obligations to watch

- **overflow**: The LCG step multiplies a state bounded by a declared range type by a constant and reduces with mod, so the product fits in 64-bit integers by types alone.
- **overflow**: Each bin counter is incremented in a loop without an invariant, so the increment must sit under an explicit guard against the type's upper bound (never reached in 1,000,000 calls), otherwise the prover cannot rule out overflow.
- **termination**: The rejection loop is a while loop inside a procedure, which gets no termination check, so no variant is needed.
- **range**: The values from the 25-way pair are mapped by integer division by 3 into 0..6 only under the guard N < 21, so the index into the bin array is provably in range.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the bin counts and the pass/fail verdict of the distribution check for the one-million-call run.

Assessed on 2026-10-15 against page revision 413912 of the [task](https://rosettacode.org/wiki/Seven-sided_dice_from_five-sided_dice) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
