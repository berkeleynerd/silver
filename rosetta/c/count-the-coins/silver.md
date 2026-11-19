# Count the coins

**Candidate: proofs likely to discharge automatically.** The 5 * 11 * 21 = 1155 triples include every affordable quarter/dime/nickel choice exactly once, so the counter guard cannot skip an iteration that should count. The independently derived required result is 242. The optional $1000 case with two additional denominations is excluded. The exact source passed admission, complete required application/library proof audit, build and manifest execution in integration run 20261107T164659-9f6192441d21; the linked assessment records the evidence scope. The linked delivery record carries the independent closing review status.

Position 43 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main enumerates Quarters in 0 .. 4, Dimes in 0 .. 10 and Nickels in 0 .. 20. It computes Total := Quarters * 25 + Dimes * 10 + Nickels * 5 with explicit grouping. When Total <= 100 and Ways < 1155 it increments Ways; the remaining cents uniquely determine the number of pennies. It prints the resulting count for 100 cents. About 21 lines.

## Proof obligations to watch

- **overflow**: Total is at most 300 from the static loop ranges. Ways is bounded 0 .. 1155 and the immediate Ways < 1155 guard makes Ways + 1 fit; at most 1155 triples exist, so the guard is harmless to the required count.

## Language surface recorded by this assessment

Integer range for loops, immutable Integer arithmetic, Integer image, bounded mutable Integer objects and scalar guard refinement.

## External effects

- **console output** (allowed): Prints only "Ways to make 100 cents with 25, 10, 5 and 1: 242" followed by LF; the optional $1000 result is not produced.

Initially assessed on 2026-10-15 against page revision 413676 of the [task](https://rosettacode.org/wiki/Count_the_coins) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-07 by Codex through targeted source review; see the [review record](../../assessment-sample-expansion-20261107.md).
