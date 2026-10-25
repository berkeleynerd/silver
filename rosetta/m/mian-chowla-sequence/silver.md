# Mian-Chowla sequence

**Candidate: proofs plausibly discharge automatically.** Every index and sum is bounded by ranged subtypes (the 100th term is 27219, so the 30000 limit is sufficient) and the loops run in a procedure, so no annotation is needed, though the loop-carried candidate and count depend on guards and the bounded output buffer needs careful shaping.

Position 229 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Keep a Boolean array Seen(1..60000) of sums already used and an array of 100 terms; for each candidate from 1 upward, a for loop over accepted terms checks whether term+candidate is already in Seen (candidate+candidate cannot collide with new sums), and on acceptance marks all term+candidate sums and 2*candidate and stores the term. The outer while loop in the Main procedure runs until 100 terms are found, with a guard on a 30000 candidate limit that rejects instead of continuing, then two for loops print the requested ranges via bounded string buffers using 'Image. About 70 lines.

## Proof obligations to watch

- **overflow**: The candidate and each stored term are subtypes of 1..30000 so every sum stays at most 60000, and the increment is guarded by an explicit candidate-limit test whose failure rejects with a visible message.
- **index**: The sum array is indexed 1..60000 and the loop-carried sums stay in range only because the term and candidate subtypes bound them, and the term array write is guarded by count < 100.
- **termination**: The search loop lives in a procedure, so no termination check arises, and it is bounded by the 100-term count and candidate limit anyway.
- **length**: Joining the numbers into an output line needs a bounded buffer sized for 30 terms of at most 5 digits plus separators, with a guarded append position.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, while loops, 'Image of scalars, string building, Put without a newline and procedures.

## External effects

- **console output** (allowed): Prints the first 30 terms and the 91st to 100th terms as text lines.

Assessed on 2026-10-15 against page revision 413177 of the [task](https://rosettacode.org/wiki/Mian-Chowla_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
