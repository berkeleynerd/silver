# N-grams

**Candidate: proofs plausibly discharge automatically.** All checks follow from ranged subtypes, for-loop indexes and short guards, with no recursion or heap, though the nested loop-carried dictionary size and counts need careful guards, so discharge is plausible rather than certain.

Position 542 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The embedded text "Live and let live" is held as a String constant, and for N in 2..4 the program scans each start position, upper-cases the N characters into a fixed 4-character key, and linearly searches a bounded dictionary (key array plus count array) for a match, incrementing its count or adding a new entry if the dictionary is not full. After the scan, a for loop over the dictionary entries prints each gram and count using 'Image into a bounded line buffer, with the case where there are fewer than N characters producing no grams. About 70 lines.

## Proof obligations to watch

- **overflow**: Dictionary size and counts are loop-carried, so they live in bounded subtypes and are incremented only under an explicit guard against the subtype maximum, which is never reached for the embedded text but must be written.
- **index**: Gram start positions and comparison offsets are for-loop indexes bounded so that i+k stays within the text, with the loop upper bound computed from 'Length and N guarded before use.
- **length**: Each gram is copied into a fixed 4-character buffer after upper-casing, and the output line is built in a bounded buffer so its computed length is within the declared capacity.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, string indexing, string building, 'Image of scalars, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints each distinct N-gram with its count, one per line.

Assessed on 2026-10-15 against page revision 388223 of the [task](https://rosettacode.org/wiki/N-grams) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
