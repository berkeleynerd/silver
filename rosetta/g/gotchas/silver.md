# Gotchas

**Candidate: proofs likely to discharge automatically.** The task is open-ended, so a program showing only gotchas that behave deterministically (division truncation, mod versus rem, 1-based array bounds, string slice bounds) needs only literal or ranged operands and for loops over array ranges, which discharge from types alone. Nothing requires demonstrating an actual run-time error, so no conflict arises.

Position 508 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

The program embeds a handful of safe gotcha demonstrations as constants and small fixed arrays: truncating integer division versus rem/mod on negatives with a nonzero literal divisor, arrays indexed from 1 and iterated with for loops over their own range, and a ranged subtype that makes the defense visible. Each section prints a description line and the computed result via 'Image concatenation, with no demonstration of actual run-time errors, so all checks follow from literal operands and declared bounds. About 45 lines.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, 'Image of scalars, arrays, for loops and string indexing.

## External effects

- **console output** (allowed): Prints each gotcha example and its defense as text lines.

Assessed on 2026-10-15 against page revision 413734 of the [task](https://rosettacode.org/wiki/Gotchas) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
