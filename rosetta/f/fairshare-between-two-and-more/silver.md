# Fairshare between two and more

**Candidate: proofs plausibly discharge automatically.** All values are small and bounded by ranged subtypes and a for-loop-based digit extraction, so checks follow from types, but careful shaping is needed to avoid a while loop in a function and to build the output text.

Position 371 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Embed the bases 2, 3, 5, 11 in a constant array and count n from 0 to 24 in a for loop; a procedure computes the digit sum mod b by repeating n mod b, n / b a fixed 32 times (stopping effectively at zero) with the running sum kept reduced modulo b in a ranged subtype. Each term is converted to text and appended to a fixed-capacity line buffer, then printed with Put_Line per base; the optional 50000-iteration turn-count part is omitted. About 55 lines.

## Proof obligations to watch

- **termination**: The digit-sum while loop would be inside a function and needs a variant, so it is restructured into a procedure (or a for loop over a fixed digit count such as 32 iterations of divide-by-base) so no termination check arises.
- **overflow**: The loop-carried digit sum is bounded by declaring it as a ranged subtype and guarding addition (or reducing modulo b every step), since digit sum modulo b equals the running modulo sum.
- **division**: The base is a constrained subtype with minimum 2 so division and mod by the base cannot be zero.
- **length**: Output lines are built in a bounded buffer sized for 25 terms of at most two digits plus the label, with Put_Line of a fixed-length slice.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, functions, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints four lines of 25 fairshare terms each.

Assessed on 2026-10-15 against page revision 411962 of the [task](https://rosettacode.org/wiki/Fairshare_between_two_and_more) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
