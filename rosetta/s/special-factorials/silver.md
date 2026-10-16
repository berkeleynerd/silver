# Special factorials

**Candidate: proofs plausibly discharge automatically.** Every operation is a bounded for-loop over small ranges with explicit overflow guards before each multiplication and addition, so checks follow from types and local guards, but several loop-carried accumulators make the program shape matter.

Position 937 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Use Long_Long_Integer values with a precomputed factorial table (0..20) built by a guarded for loop, then compute sf, H (by repeated guarded multiplication rather than **), af, the exponential factorial (n^(n-1)^... evaluated bottom-up with a guarded power loop, 0$ and 1$ being 1) and the inverse factorial rf as a for-loop scan of the table returning a found flag plus value. Main loops over n from 0 to 9, printing each value or 'too large' when a guard fails, prints 0$ to 4$, and prints rf for the factorials 1 through 10! and 'undefined' for 119; the optional digit count of 5$ is omitted. About 110 lines.

## Proof obligations to watch

- **overflow**: Running products in sf, H, the factorial table and the exponential factorial are loop-carried, so each multiplication is guarded by a comparison against Long_Long_Integer'Last divided by the multiplier, and a failed guard prints 'too large' to match the task's allowance to show only values the type can handle.
- **division**: The guard divisions use a multiplier that is a for-loop index starting at 1 or a declared positive subtype, so the divisor is provably nonzero.
- **index**: The factorial table is indexed by a subtype 0..20 and the inverse factorial scans with a for loop over the table's own range, so indexes are routine.
- **termination**: All loops are for loops or bounded scans inside functions, with no while loops or recursion in functions, so no variant is needed.
- **other**: Alternating-factorial signed accumulation is bounded by the same guarded factorials (n at most 9), so the sum fits in Long_Long_Integer, but the prover must see the bound through the loop-carried sum, which a range guard before each add provides.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, functions, procedures, 'Image of scalars, Put without a newline, string building and conditional expressions.

## External effects

- **console output** (allowed): Prints the tables of sf, H, af, ef and rf results to standard output.

Assessed on 2026-10-15 against page revision 404192 of the [task](https://rosettacode.org/wiki/Special_factorials) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
