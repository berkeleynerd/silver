# FizzBuzz

**Candidate: proofs likely to discharge automatically.** The static 1 through 100 loop and literal nonzero divisors 15, 5 and 3 fit the delivered interval-integer-division rules. The branch order distinguishes multiples of both before either individual divisor. The external review confirmed admission of this approach. This is a current-language assessment, not a delivered manifest sample or a new proof/build/execution record.

Position 30 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

A parameterless Main uses a for loop over the static Integer range 1 .. 100 and tests (I mod 15), (I mod 5) and (I mod 3) in an if/elsif/else chain. The branches call Silver_IO.Put_Line with FizzBuzz, Buzz or Fizz respectively; the else branch prints ordinary Integer'Image (I), including Ada's leading space. The task does not require trimming that space. No computed-length string buffer or trimming operation is used. About 16 lines.

## Language surface recorded by this assessment

Integer range for loops, interval-checked Integer division and Integer image.

## External effects

- **console output** (allowed): Prints 100 lines, one per integer, to standard output via Put_Line.

Initially assessed on 2026-10-15 against page revision 415487 of the [task](https://rosettacode.org/wiki/FizzBuzz) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-27 by Codex through targeted source review; see the [review record](../../assessment-arrays-20261027.md).
