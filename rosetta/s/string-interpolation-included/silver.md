# String interpolation (included)

**Candidate: proofs likely to discharge automatically.** This future library candidate performs replacement in an existing template using a standard Ada operation, with fixed valid positions and a statically bounded result. It neither claims native interpolation syntax nor treats plain concatenation as interpolation; admission still requires the operation's complete contract and source-correspondence justification.

Position 1573 in the [progression](../../progression.md#stage-42), in stage 42, which adds fixed string replacement.

## Approach

Follow the captured Ada answer's library-based interpretation: declare Original as the constant String "Mary had a @__@ lamb" and Little as a String variable containing "little", then print Ada.Strings.Fixed.Replace_Slice (Original, 12, 15, Little). The fixed task text makes the placeholder positions static, so no search operation or application-written interpolation routine is needed. About 12 lines.

## Language surface recorded by this assessment

Fixed string replacement.

## External effects

- **console output** (allowed): Prints Mary had a little lamb after the admitted library operation replaces the marker with the value held in Little.

Initially assessed on 2026-10-15 against page revision 413061 of the [task](https://rosettacode.org/wiki/String_interpolation_%28included%29) by claude-opus-5-5 at high effort; current confidence medium. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-reconciliation-20261025.md).
