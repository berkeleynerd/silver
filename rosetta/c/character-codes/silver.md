# Character codes

**Candidate: proofs likely to discharge automatically.** The isolated direct Character Pos approach rejected; Character Val was not separately isolated, and both attributes remain outside Silver. An executed lookup alternative covers character-to-code and code-to-character for all printable ASCII 32 .. 126: the independently rerun complete stdout matched 95 lines/597 bytes, with compiler, GNATprove and execution exit 0 and empty stderr. The overwritten Letter initializer produced an INEFFECTIVE advisory. Nonprintable codes and Unicode are unmeasured. Pos/Val are possible conveniences rather than a remaining blocker for this bounded task. The original surface mapping is retained for separate coverage reconciliation; these observations add no delivered sample or supported task mapping in this batch.

Position 435 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Use an initialized String lookup table containing every printable ASCII Character in code order, 32 .. 126. For each Code, obtain Letter from Codes ((Code - 31)); search all 95 table positions with a typed Character comparison to compute Found := (I + 31). Separately index the table from Code and write that Character into a one-cell initialized String for output. Print Integer Image (Found), a colon and the one-cell String. This computes both directions over all 95 values without Character attributes or Character concatenation. About 12 lines.

## Language surface recorded by this assessment

Characters, integers, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the code of a character and the character for a code with Put_Line.

Initially assessed on 2026-10-15 against page revision 415359 of the [task](https://rosettacode.org/wiki/Character_codes) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-18 by Codex through targeted source review; see the [review record](../../../docs/bounded-string-building-samples.md).
