# Hofstadter Q sequence

**Candidate: proofs likely to discharge automatically.** Iterative table filling replaces the recursive memoized solution, and every index and range check is covered by a guard placed immediately before use, so no invariant is needed. The guards never fire for this sequence at the required sizes, and rejection is a specified outcome if they did.

Position 67 in the [progression](../../progression.md#stage-3), in stage 3.

## Approach

Fill a constant-size array of 100000 elements typed with a subtype 0..100000 iteratively with a for loop from 3, never recursion, seeding terms 1 and 2 as 1. Before each computation guard that both look-back values are smaller than n and that their sum fits the element subtype, rejecting visibly if not, then count decreases in the same loop. Print terms 1 to 10 with Put and Integer'Image, then term 1000 and the count. About 55 lines.

## Proof obligations to watch

- **index**: The indexes n-Q(n-1) and n-Q(n-2) are loop-carried values, so each is guarded just before use (value less than n, hence at least 1) with a visible Reject outcome otherwise.
- **range**: The sum of two terms is stored in a 0..100000 element subtype, so a guard that the sum is at most 100000 precedes the store, rejecting otherwise.
- **overflow**: Terms are bounded by the element subtype so the sum of two and the decrease counter (at most 100000) stay far below the Integer limit.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the first ten terms, the 1000th term and the decrease count.

Assessed on 2026-10-15 against page revision 411708 of the [task](https://rosettacode.org/wiki/Hofstadter_Q_sequence) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
