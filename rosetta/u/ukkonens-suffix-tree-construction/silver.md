# Ukkonen’s suffix tree construction

**Excluded from Silver: clock.** The task needs Ukkonen suffix tree construction over a bounded alphabet. This fits arrays of node records with integer indices and iterative loops, with no recursion or pointers. It also needs pi digits to 100000 places, which needs fixed-capacity big-number arithmetic (or an embedded or file-read digit source), console output and a clock for timing. No fixed Oracle rule is broken.

## Language surface beyond today's Silver

Integers, characters, arrays, records, enumerations, loops, subprograms and big numbers.

## External effects

- **console output** (allowed): Print the longest repeated digit string(s) and positions for each of the three sizes, plus timing figures.
- **clock** (not allowed): The task requires timing each run to demonstrate roughly linear scaling.

Assessed on 2026-10-15 against page revision 414990 of the [task](https://rosettacode.org/wiki/Ukkonen%E2%80%99s_suffix_tree_construction) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
