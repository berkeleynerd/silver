# XXXX redacted

**Candidate: proofs plausibly discharge automatically.** Everything is bounded string and index arithmetic over fixed-length strings, inside procedures so no termination check applies, and every index is guardable by explicit tests. The nested scan loops with several loop-carried positions need careful guard placement, so discharge is plausible rather than routine.

Position 567 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The sentence and the two targets are embedded fixed-length String constants, and a Redact procedure copies the sentence into an out String of the same length and overwrites ranges with 'X'. It scans words with while loops bounded by Len, trims non-letter edges to get the core, then handles whole-word equality, partial-match windows (for loops over start positions with case folding via a small function) and overkill by overwriting the whole core; main loops over the two targets and Boolean option combinations printing labeled lines. The optional grapheme stretch is left out and the text is ASCII. About 120 lines.

## Proof obligations to watch

- **index**: Word-boundary scans and pattern-window comparisons use loop-carried positions, so each access is preceded by an explicit bounds guard (Pos <= Len and then ...) and positions live in a subtype 0 .. Len + 1.
- **overflow**: Position increments and Start + Pattern_Length - 1 sums stay safe because the sentence and pattern are fixed-length subtypes with small bounds and loop positions are range-typed.
- **range**: Lower-casing a letter through 'Pos and 'Val is guarded by an explicit test that the character is in 'A' .. 'Z' just before conversion.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, string indexing, string building, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): Prints a header per redaction target and one labeled redacted sentence per option combination.

Assessed on 2026-10-15 against page revision 400401 of the [task](https://rosettacode.org/wiki/XXXX_redacted) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
