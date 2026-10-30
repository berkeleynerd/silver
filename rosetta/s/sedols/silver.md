# SEDOLs

**Candidate: proofs likely to discharge automatically.** All loops are fixed-range for loops over constant arrays and every value is bounded by declared subtypes, so no loop-carried fact needs an invariant; the invalid-character path becomes a visible outcome instead of Constraint_Error.

Position 760 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed the ten example SEDOLs in a constant array of 6-character Strings with a constant weight array (1,3,1,7,3,9); a for loop over indices 1..10 calls a procedure that, for each of six positions, maps the character to a 0..35 value via a case statement (digits and non-vowel letters valid, otherwise a Valid flag set False). If valid it computes the check digit as (10 - Sum mod 10) mod 10 and prints the SEDOL with the digit appended through Put_Line and a Character'Val conversion, otherwise it prints a visible 'invalid' line. About 55 lines.

## Proof obligations to watch

- **overflow**: The weighted sum accumulates in a loop, but each term is at most 35*9 and there are six terms, so a subtype Sum range of 0..2000 with a per-term bound from the character-value subtype lets the addition discharge from types alone.
- **range**: The character-to-value mapping is done by a case on the Character with an explicit rejecting branch, so the resulting value lies in a declared 0..35 subtype, and the final (10 - Sum mod 10) mod 10 is bounded by mod.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, for loops, case statements, procedures, functions and Boolean objects.

## External effects

- **console output** (allowed): Prints each six-character SEDOL followed by its check digit, one per line.

Assessed on 2026-10-15 against page revision 413896 of the [task](https://rosettacode.org/wiki/SEDOLs) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
