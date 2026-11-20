# Sequence of non-squares

**Candidate: proofs likely to discharge automatically.** Replacing sqrt with the integer interval identity keeps all arithmetic in small declared ranges inside for loops, so every check follows from types and static bounds with no invariant needed.

Position 120 in the [progression](../../progression.md#stage-5), in stage 5.

## Approach

Avoid floating point by using the integer identity that round(sqrt n) = k exactly when k*k-k+1 <= n <= k*k+k, so an outer for loop over k in 1..1000 and an inner for loop over n in that interval (clamped to 1_000_000) compute m = n + k with k a ranged subtype. Each m is tested against k*k and (k+1)*(k+1) and a Boolean flag records any square; values for n up to 22 are printed with scalar images and Put, then a final line reports that no squares were found. About 40 lines.

## Proof obligations to watch

- **overflow**: The k*k+k bounds and n+k sums stay below about 1_001_000 because k is a subtype 1..1000, so the provers discharge them from ranges alone.
- **range**: The inner loop's upper bound is clamped to 1_000_000 with a guard and k*k-k+1 is at least 1 for k in 1..1000, so no loop-carried value needs an invariant.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the 22 sequence values and a final line stating whether any square was found.

Assessed on 2026-10-15 against page revision 413904 of the [task](https://rosettacode.org/wiki/Sequence_of_non-squares) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
