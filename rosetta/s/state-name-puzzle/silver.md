# State name puzzle

**Candidate: proofs plausibly discharge automatically.** The task is bounded nested for-loop enumeration with per-letter counts over embedded data, so every check follows from declared ranges and local guards without annotations, though the amount of guarded buffer and counter handling needs careful program shape.

Position 751 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed the 50 states and the 5 fictitious names as padded fixed-length Character buffers with explicit lengths in a constant array, normalize each to lowercase letters only, drop exact duplicate normalized names with guarded appends into a bounded table, and give each remaining state a 26-entry letter-count array. Four nested for loops over the table enumerate pairs i<j and k<l with i<k and all four indexes distinct, compare the summed letter counts across the 26 letters, and print each match with Put_Line from bounded string-building buffers, once for the original list and once for the extended list. Table size, name length and count ranges are fixed constants, and each loop-carried count is guarded before it increments. About 170 lines.

## Proof obligations to watch

- **overflow**: Letter counts and the unique-state counter are loop-carried values, so each is declared in a bounded range and guarded before it increments, and the summed counts stay within a small range type.
- **index**: Mapping a character to a letter slot needs a guard that the character lies in 'a'..'z' before the position computation, and name offsets are bounded by explicit length guards.
- **length**: Output lines are assembled in a bounded buffer sized for four names plus separators, with each append guarded by the remaining capacity.
- **termination**: Only for loops are used in procedures, so no variant is needed.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, string indexing, string building, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints each matching pair of state pairs for the original and the extended lists.

Assessed on 2026-10-15 against page revision 413927 of the [task](https://rosettacode.org/wiki/State_name_puzzle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
