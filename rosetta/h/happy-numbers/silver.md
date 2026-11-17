# Happy numbers

**Candidate: proofs likely to discharge automatically.** Three extractions cover every declared input and the static guard cannot skip a square. The first transformation enters 0..243 and one is absorbing. If 244 images avoid one, two repeat among the 243 non-one states, so no later first visit to one is possible. Thus the test decides happiness on the complete 0..999 domain, rather than using an arbitrary cutoff. The complete positive prefix through 31 contains exactly the required first eight. The [reconciliation](../../../rosetta/assessment-scalar-function-batch-20261108.md) preserves the original assessment attribution and links the separately reviewed Linux application evidence; final combined integration and independent delivery status remain in the batch delivery record.

Position 78 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Use samples/rosetta_happy_numbers.adb: Sum_Squared_Digits on 0..999 extracts three decimal digits and returns their square sum in 0..243 under a <=162 pre-addition guard. Is_Happy assigns the earlier helper call 244 times, then returns whether Current = 1. Main scans the entire positive prefix 1..31, assigns each Boolean call and prints only happy candidates. About 43 lines.

## Proof obligations to watch

- **range**: At most two earlier squared digits contribute 162; adding a square <=81 fits 0..243. Every helper result fits the caller input domain 0..999.
- **termination**: The loops are counted; the absorbing-state/repetition argument proves that 244 transformations suffice to decide happiness throughout the declared domain.

## Language surface recorded by this assessment

Named Integer subtypes, bounded components and scalar signatures, small nonrecursive scalar functions, bounded mutable Integer objects, scalar Boolean objects and expressions, Integer range for loops, interval-checked Integer division, scalar guard refinement and Integer image.

## External effects

- **console output** (allowed): Prints exactly the first eight happy numbers: 1, 7, 10, 13, 19, 23, 28 and 31.

Initially assessed on 2026-10-15 against page revision 415022 of the [task](https://rosettacode.org/wiki/Happy_numbers) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-08 by Codex through targeted source review; see the [review record](../../assessment-scalar-function-batch-20261108.md).
