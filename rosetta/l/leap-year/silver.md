# Leap year

**Candidate: proofs likely to discharge automatically.** The inline Gregorian predicate covers ordinary leap/common years, common century years and century years divisible by 400. Only literal nonzero divisors are used; no function or computed String buffer is needed. The exact source passed admission, complete required application/library proof audit, build and manifest execution in integration run 20261107T164659-9f6192441d21; the linked assessment records the evidence scope. The linked delivery record carries the independent closing review status.

Position 36 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main iterates over a constant Gregorian_Year array bounded 1 .. 2400, containing 1600, 1700, 1800, 1900, 1996, 1999, 2000, 2004, 2100, 2200, 2300 and 2400. An inline condition tests divisibility by 400 or divisibility by 4 but not 100, then prints leap or common. About 19 lines.

## Language surface recorded by this assessment

Put without a newline, Integer image, interval-checked Integer division, fixed-size Integer arrays, constant Integer-array iteration and named Integer subtypes and bounded components.

## External effects

- **console output** (allowed): Prints twelve labelled leap/common verdicts, including leap for 1600, 2000 and 2400 and common for the other demonstrated century years.

Initially assessed on 2026-10-15 against page revision 415546 of the [task](https://rosettacode.org/wiki/Leap_year) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-07 by Codex through targeted source review; see the [review record](../../assessment-sample-expansion-20261107.md).
