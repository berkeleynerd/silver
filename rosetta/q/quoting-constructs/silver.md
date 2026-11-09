# Quoting constructs

**Candidate: proofs likely to discharge automatically.** The task is open-ended documentation of quoting constructs, so a straight-line program of literals, constants and bounded concatenation needs only static checks. No loop-carried values, arithmetic on inputs or recursion arise, so proofs should discharge automatically.

Position 445 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

A parameterless Main holds String constants showing Ada's quoting forms (double-quoted literals with a doubled quote, concatenation with Character'Val for newline, character literals, and based or underscored numeric literals). It prints each example plus a fixed explanatory line with Put_Line, using Integer'Image only on constants whose lengths are statically bounded. There are no loops and no input, so all control flow is straight-line. About 45 lines.

## Language surface recorded by this assessment

Integers, characters and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each example of an Ada quoting construct with its explanation via Put_Line.

Assessed on 2026-10-15 against page revision 413290 of the [task](https://rosettacode.org/wiki/Quoting_constructs) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
