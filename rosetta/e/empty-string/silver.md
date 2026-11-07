# Empty string

**Candidate: proofs likely to discharge automatically.** Mutable empty and nonempty String variables demonstrate the required assignment and checks using baseline String/argument operations. Manifest cases cover no argument, an explicit empty argument, Silver, one space, the 4096-byte limit, and rejection of extra arguments, 4097 bytes or a tab. The exact source passed admission, complete required application/library proof audit, build and manifest execution in integration run 20261107T164659-9f6192441d21; the linked assessment records the evidence scope. The linked delivery record carries the independent closing review status.

Position 49 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main declares mutable String variables Empty := "" and Nonempty := "Silver", assigns "" to Empty, and tests Empty = "" and Nonempty /= "". It initializes Input with First_Or_Default (""), checks Input_Is_Valid, then prints whether Input'Length = 0; invalid input calls Reject. About 25 lines.

## External effects

- **console output** (allowed): For valid input, prints the empty-variable and nonempty-variable checks and one argument emptiness verdict; rejection prints nothing.
- **arguments** (allowed): Reads the optional first printable-ASCII argument, with the existing 4096-byte bound and input-validity check.
- **exit status** (allowed): Rejects an extra argument, an overlong argument or a tab with status 1; valid cases have status 0.

Initially assessed on 2026-10-15 against page revision 412762 of the [task](https://rosettacode.org/wiki/Empty_string) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-07 by Codex through targeted source review; see the [review record](../../assessment-sample-expansion-20261107.md).
