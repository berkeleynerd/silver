# I before E except after C

**Candidate: proofs likely to discharge automatically.** All checks follow from bounded buffers, for-loop indexes over the line length and guarded counters, with no annotation needed because the loop-carried counters are bounded by an explicit visible rejection limit.

Position 1350 in the [progression](../../progression.md#stage-24), in stage 24.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

A procedure reads unixdict.txt through an admitted line-reading library operation into a bounded String buffer plus length, lowercases via Character comparisons, and a for loop over window start positions tests each 'cie', 'cei', 'ie' and 'ei' occurrence, setting per-word Boolean flags so each word counts once. Counters are ranged-subtype Naturals with a guard-then-reject check before each increment, and a final procedure compares counts with integer multiplication by 2 and prints counts and verdicts using integer image conversion. The stretch goal is left out. About 90 lines.

## Proof obligations to watch

- **overflow**: The four counters are loop-carried across the line-reading loop, so each increment is preceded by a guard against a documented maximum word count and exceeding it rejects the input visibly.
- **index**: Each line is held in a fixed-capacity buffer with a length, and the scan uses a for loop whose upper bound is the length minus 2, so the three-character window indexes stay in range.
- **length**: Lines longer than the buffer capacity are rejected with a specified outcome rather than truncated.
- **overflow**: The plausibility test compares ie against 2 times ei using counters bounded well below the integer limit so the multiplication cannot overflow.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, file input and exit status.

## External effects

- **files** (allowed): The program reads the unixdict.txt word list from a named file line by line.
- **console output** (allowed): It prints the four counts and the plausibility verdicts.
- **exit status** (allowed): Unreadable files, overlong lines or too many words are rejected with a visible failure status.

Assessed on 2026-10-15 against page revision 413747 of the [task](https://rosettacode.org/wiki/I_before_E_except_after_C) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
