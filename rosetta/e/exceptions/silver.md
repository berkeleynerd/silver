# Exceptions

**Excluded from Silver: local exceptions.** SPARK 16.1 supports this local raise and handler without an Exceptional_Cases annotation, but Silver excludes local exceptions until their admission and composition rules are established.

## Approach

Declare one user exception in Main, raise it explicitly in Main, and handle it in the same subprogram with a literal Put_Line call. No exception crosses a call and all ordinary run-time checks must still prove. About 10 lines.

## Language surface beyond today's Silver

Local exceptions.

## External effects

- **console output** (allowed): Prints a message from the handler to demonstrate that the locally raised exception was caught.

Initially assessed on 2026-10-15 against page revision 415544 of the [task](https://rosettacode.org/wiki/Exceptions) by claude-opus-5-5 at high effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-15 by Codex through targeted source review; see the [review record](../../review-343c2f8.md).
