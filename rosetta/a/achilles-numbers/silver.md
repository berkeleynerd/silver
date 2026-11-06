# Achilles numbers

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded by a fixed 99_999 limit and trial divisors up to 316, so loops are for loops or while loops inside procedures with guards before every multiplication, and no annotation is needed; the provers must handle the modest nonlinear totient and power updates.

Position 280 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Numbers are a subtype 1..99_999; procedures with for loops over trial divisors 2..316 (the square root of the limit) compute exponent-by-division to test powerful (every exponent at least 2), then a perfect-power test tries each base with guarded repeated multiplication, and a totient procedure does the same trial factoring with a leftover prime step. A single for loop over 1..99_999 collects the first 50 Achilles numbers, the first 20 strong ones, and tallies 2 to 5 digit counts into a small array, printing with Put and Image. About 130 lines.

## Proof obligations to watch

- **overflow**: Perfect-power test multiplies a loop-carried power by the base, so it is guarded by checking the power is at most N before multiplying, with the power held in a wide subtype so the product provably fits.
- **range**: Totient updates Tot := Tot - Tot / P on a loop-carried subtype value, which needs the prover to see the result stays at least 1 for P at least 2, a modest nonlinear fact that may need careful shaping.
- **division**: Divisors come from for-loop indexes starting at 2 or from guarded remainders, so non-zero follows from the loop range.
- **range**: The scan counter is bounded by a fixed Limit of 99999 with an explicit exit guard, so the search cannot walk past the type, and the 50-th and 20-th results are checked to be found within that limit with a specified message otherwise.
- **index**: Digit-count array is indexed 2..5 only after a guard that the digit class lies in that range.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the 50 Achilles numbers, the 20 strong ones and the per-digit-count tallies to standard output.

Assessed on 2026-10-15 against page revision 412046 of the [task](https://rosettacode.org/wiki/Achilles_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
