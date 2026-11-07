# Unicode strings

**Candidate: proofs likely to discharge automatically.** The task asks only for a discussion plus a demonstration, so a straight-line program of constant strings and Put_Line calls needs no loop-carried values, and every check follows from static string lengths.

Position 435 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

The program holds fixed String constants for the discussion text and for sample words in several scripts, with the non-ASCII UTF-8 bytes spelled as Character'Val values joined by bounded concatenation so the source stays plain ASCII. It prints each line with Silver_IO.Put_Line and uses a 'Length comparison to show that byte length differs from code point count, with no loops or input. About 25 lines.

## Language surface recorded by this assessment

Characters and string building.

## External effects

- **console output** (allowed): The program prints a short discussion of Unicode support and a few UTF-8 demonstration strings to standard output.

Assessed on 2026-10-15 against page revision 415218 of the [task](https://rosettacode.org/wiki/Unicode_strings) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
