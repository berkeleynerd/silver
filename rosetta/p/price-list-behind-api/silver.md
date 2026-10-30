# Price list behind API

**Candidate: proofs plausibly discharge automatically.** All data lives in fixed arrays with price-bounded indexes and for loops, and the one while loop is in a procedure, so checks follow from types and guards; the loop-carried counters and the output formatting need careful guarding, hence plausible.

Position 622 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Generate 100,000 prices with a bounded LCG (mod reduced into 0..100_000) into a histogram array of counts indexed by price, then implement get_max_price and get_prange_count as functions over prefix sums or the histogram using for loops. A procedure with a while loop walks prices 0..max, closing a range whenever adding the next price's count would exceed 5,000 (a single over-large price becomes its own range), storing ranges in a fixed-capacity array and printing each with Integer'Image, then checking the counts sum to the total. About 110 lines.

## Proof obligations to watch

- **overflow**: Histogram increments and the running range count are loop-carried with no invariant, so each is guarded (increment only below a cap, add only when the sum stays at most 5,000) and the generator uses a modulus small enough that multiplication fits in 64 bits.
- **index**: Range-array writes use a loop-carried counter, so a guard on the fixed capacity (100_001 ranges, enough for one per price) precedes each store.
- **termination**: The range-splitting while loop sits in a procedure, which gets no termination check, and the price scan advances a bounded index each iteration.
- **stack**: Several 100K-element arrays are large locals, and stack exhaustion is not proved, so it rests on the memory premise.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and records.

## External effects

- **console output** (allowed): Prints the ascending price ranges and their item counts.

Assessed on 2026-10-15 against page revision 400991 of the [task](https://rosettacode.org/wiki/Price_list_behind_API) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
