# Square root by hand

**Candidate: proofs plausibly discharge automatically.** The spigot is a bounded loop of small digit-array arithmetic whose operands are all bounded by digit subtypes and guarded carries, so it should prove without annotations, but fixed-capacity big-number carry loops require careful shaping. The task's 'forever' option is met by a documented digit limit, which Oracle rule 7 allows.

Position 1380 in the [progression](../../progression.md#stage-26), in stage 26.

## Approach

Implement the classic digit-by-digit (long-hand) square root of an embedded constant such as 2, bringing down two-digit pairs (zero pairs after the radicand ends), with the remainder and the running 20*root held in fixed-capacity digit arrays sized for a documented maximum digit count N (for example 50). Each step finds the next digit by a for loop over 0..9 using big-number multiply-small, compare and subtract procedures, then outputs the digit with Put and the decimal point at the right position. The requested digit count is a constant (or a validated first argument rejected when outside 1..N), so the loop runs a bounded number of times. About 130 lines.

## Proof obligations to watch

- **overflow**: Remainder and 20*root are fixed-capacity base-10 digit arrays, and the multiply-by-small, add and subtract carry loops stay safe only because digit and carry subtypes bound every intermediate (digit <= 9, carry <= small constant).
- **index**: Digit-array indexes are for-loop indexes over the array's own range, but the carry out of the top digit needs an explicit guard that rejects or stops when the fixed capacity would be exceeded.
- **range**: The trial-digit search (largest d in 0..9 with (20p+d)*d <= remainder) is a bounded for loop over a digit subtype so d never leaves 0..9, and the Character conversion of d is safe by that subtype.
- **termination**: All loops are for loops or while loops inside procedures, so no variant is needed and the digit count is a fixed documented limit.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, for loops, while loops, procedures, big numbers and Put without a newline.

## External effects

- **console output** (allowed): Each decimal digit of the root is written to standard output as it is generated.

Assessed on 2026-10-15 against page revision 410004 of the [task](https://rosettacode.org/wiki/Square_root_by_hand) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
