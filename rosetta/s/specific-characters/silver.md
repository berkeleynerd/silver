# Specific characters

**Candidate: proofs plausibly discharge automatically.** Every index and bound follows from Character-indexed tables and for loops, with no while loops or recursion, so the only non-routine checks are loop-carried tallies and counters, which saturating guards bound without altering results.

Position 1011 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Embed the three example strings as constants and use a procedure that fills a count table indexed by Character (range 0..3, saturating at 3) for a String parameter. For each string, a for loop over all Character values counts those with own tally exactly 2 and zero tally in the other two strings (specific), and those with tally above 0 that are not specific (extra credit). Results are printed with Integer'Image through Put_Line. About 80 lines.

## Proof obligations to watch

- **overflow**: Per-character tallies and distinct-character counters are loop-carried, so each increment is guarded (tally saturates at 3, which cannot change the exactly-twice test; counters are guarded against their 0..256 type bound).
- **index**: Counts are indexed by Character over its full type range and strings are walked with for loops over S'Range, so every index follows from the types.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, unconstrained arrays, string indexing, 'Image of scalars, for loops, procedures and Boolean objects.

## External effects

- **console output** (allowed): Prints the per-string specific-character counts and the extra-credit counts, one number per line.

Assessed on 2026-10-15 against page revision 413923 of the [task](https://rosettacode.org/wiki/Specific_characters) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
