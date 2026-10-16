# Exceptions/Catch an exception thrown in a nested call

**Excluded from Silver: annotations, run-time error.** The nested-call propagation requires author-written exceptional contracts, and the deliberate uncaught U1 outcome cannot satisfy the required proof obligations; local handlers alone are not a conflict.

## Language surface recorded by this assessment

Subprograms.

## Oracle conflicts

- **annotations**: The required propagation from baz through intervening calls needs Exceptional_Cases contracts on program-defined subprograms, which Silver authors cannot supply.
- **run-time error**: The task deliberately leaves U1 uncaught so that it propagates out of the program, conflicting with proof of every required exception obligation.

## External effects

- **console output** (allowed): The program must print what happens when it runs: that U0 was caught and U1 propagated.

Initially assessed on 2026-10-15 against page revision 413261 of the [task](https://rosettacode.org/wiki/Exceptions/Catch_an_exception_thrown_in_a_nested_call) by claude-opus-5-5 at high effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-15 by Codex through targeted source review; see the [review record](../../../review-343c2f8.md).
