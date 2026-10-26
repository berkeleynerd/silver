# FizzBuzz

**Candidate: proofs likely to discharge automatically.** Static loop bounds and nonzero literal divisors make the arithmetic a candidate for the current narrow interval-checked modulo capability. The existing broad integer-division dependency is retained pending approach review and migration; this assessment does not establish a delivered sample or automatic discharge.

Position 106 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A parameterless Main uses a for loop over the static Integer range 1 .. 100 and tests (I mod 15), (I mod 5) and (I mod 3) in an if/elsif/else chain. The branches call Silver_IO.Put_Line with FizzBuzz, Buzz or Fizz respectively; the else branch prints ordinary Integer'Image (I), including Ada's leading space. The task does not require trimming that space. No computed-length string buffer or trimming operation is used. About 16 lines.

## Language surface recorded by this assessment

Integer range for loops, integer division and Integer image.

## External effects

- **console output** (allowed): Prints 100 lines, one per integer, to standard output via Put_Line.

Initially assessed on 2026-10-15 against page revision 415487 of the [task](https://rosettacode.org/wiki/FizzBuzz) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-division-20261025.md).
