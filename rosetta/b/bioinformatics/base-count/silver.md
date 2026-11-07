# Bioinformatics/Base count

**Candidate: proofs likely to discharge automatically.** All checks follow from the constant string's static bounds, for-loop indexes over its own range, and a guard before each counter increment, so no annotation is needed. The only care is the loop-carried counters and the fixed-width text formatting.

Position 768 in the [progression](../../../progression.md#stage-13), in stage 13.

## Approach

The 500-base sequence is embedded as a constant String, printed 70 bases per line with a for loop over line numbers, each line prefixed by padded start..end positions built from 'Image into a bounded buffer. A second for loop over the sequence's own index range uses a case statement on each Character to bump one of four bounded counters, rejecting any other character, then prints A, C, G, T and the total (the sequence length). About 70 lines.

## Proof obligations to watch

- **overflow**: The four loop-carried counters are discharged by a guard before each increment (counter below its type's upper bound, otherwise reject), since without an invariant only the type range is known after the first iteration.
- **index**: Line slices use a for loop over line numbers with start and end computed from constants and clamped by a guard against the sequence length, so slice bounds follow from static bounds.
- **length**: Each output line is built in a fixed-size bounded buffer (position prefix of width 3 plus up to 70 characters), sized statically so no length check can fail.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing, string building, 'Image of scalars, case statements, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the pretty-printed sequence lines and the per-base and total counts.

Assessed on 2026-10-15 against page revision 414078 of the [task](https://rosettacode.org/wiki/Bioinformatics/Base_count) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
