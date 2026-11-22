# Show the (decimal) value of a number of 1s appended with a 3, then squared

**Candidate: proofs likely to discharge automatically.** The measured obstacle is the direct wide-type/range and larger-square limitation, rather than missing Integer Image or bounded output building. Required n remains 0 .. 7. Rejected direct approaches do not establish impossibility of a digit or multiword solution; those alternatives are unassessed. The original surface mapping is retained for separate coverage reconciliation; these observations add no delivered sample or supported task mapping in this batch.

Position 108 in the [progression](../../progression.md#stage-4), in stage 4.

## Approach

Preserve the required eight cases n = 0 .. 7: roots 3, 13, 113, 1113, 11113, 111113, 1111113 and 11111113. The direct wide-integer-type/range approach refuses, and a required larger square also refuses under Standard.Integer. Do not reduce n to fit. A fixed-capacity digit or multiword algorithm is a possible different approach, but was not explored or executed. About 35 lines.

## Proof obligations to watch

- **overflow**: Silver uses signed 32-bit Standard.Integer. The largest required root is 11111113 and its square is 123456832098769, beyond Integer; no admitted 64-bit type/range or measured alternative resolves this direct approach.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints eight lines, one per n, showing the number and its square.

Initially assessed on 2026-10-15 against page revision 407865 of the [task](https://rosettacode.org/wiki/Show_the_%28decimal%29_value_of_a_number_of_1s_appended_with_a_3,_then_squared) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-18 by Codex through targeted source review; see the [review record](../../../docs/bounded-string-building-samples.md).
