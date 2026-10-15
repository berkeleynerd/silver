# Inverted syntax

**Candidate: proofs likely to discharge automatically.** The program uses only Booleans, a small ranged counter and a plain loop with exit when, and each check follows from declared ranges and the guard just before the increment. Ada has no true inverted assignment or trailing-if syntax, so the faithful demonstration is the traditional forms plus exit when, which needs no annotation.

Position 187 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

The main procedure declares Boolean variables Raining and Need_Umbrella and a counter Foo of a 1..10 subtype, then shows the traditional conditional (if Raining then Need_Umbrella := True) and the traditional assignment, printing results with if and Put_Line. It then shows the only inverted-style form Ada has, a loop whose first statement is exit when Foo >= 10 before Foo := Foo + 1, and prints the final counter value as a literal-based message chosen by a comparison. About 30 lines.

## Proof obligations to watch

- **range**: The loop counter is a 1..10 subtype incremented after an immediately preceding exit when Foo >= 10, so the increment's range check follows from that guard alone.

## Language surface beyond today's Silver

Boolean objects, integers, ranged subtypes and while loops.

## External effects

- **console output** (allowed): The program prints a line for each traditional and inverted-style form it demonstrates.

Assessed on 2026-10-15 against page revision 410861 of the [task](https://rosettacode.org/wiki/Inverted_syntax) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
