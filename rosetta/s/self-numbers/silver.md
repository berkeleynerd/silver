# Self numbers

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded by ranged types, a fixed-size table and fixed-size windows, with only for loops and simple guards, so no annotation should be needed. It is plausible rather than likely because of the loop-carried count, the segment arithmetic and the roughly 10^9-iteration run that must stay within declared ranges.

Position 393 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The program uses a segmented sieve: a fixed 1,000,000-entry Boolean window, a precomputed 1000-entry digit-sum table, and an outer for loop over about 1100 segments. For each segment it clears the window, marks g + digitsum(g) for every g from the segment start minus 90 up to the segment end, then scans the window in order, counting unmarked values. It prints the first 50 and the 100000000th self number, then prints whether the result equals 1022727208 (confirm or dispute). The extra-credit Mersenne proof is skipped as optional. About 80 lines.

## Proof obligations to watch

- **overflow**: The digit sum is computed without a loop as three bounded table lookups on g/10^6, g/10^3 mod 10^3 and g mod 10^3, so g plus its digit sum stays within a ranged Value type up to 1_100_000_000 by types alone.
- **index**: Each mark of g + digit_sum(g) in the segment window is guarded by a comparison against the window start and end, so the index check follows from the guard.
- **range**: The self-number counter is a loop-carried value, so its increment is guarded by count being below the limit (100_000_000), which holds trivially because the outer loop stops when reached.
- **initialization**: The digit-sum table (entries 0..27) is built by a for loop using the direct formula i/100 + (i/10 mod 10) + i mod 10, so no recurrence on earlier entries is needed.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 50 self numbers, the 100000000th self number, and a confirm or dispute verdict.

Assessed on 2026-10-15 against page revision 414015 of the [task](https://rosettacode.org/wiki/Self_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
