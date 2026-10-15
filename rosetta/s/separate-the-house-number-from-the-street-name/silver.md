# Separate the house number from the street name

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged subtypes, a bounded for loop over fixed-length data and a guard before each store or use of the loop-carried word count, so no annotation is needed. It is plausible rather than likely because the index arithmetic over carried word positions depends on careful guard placement.

Position 1024 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

The 32 test addresses are embedded as a constant array of records holding a fixed 40-character buffer and a length. A for loop over the characters of each address records word start and end positions into bounded arrays, with a guard before each store, and then if statements apply the rule (last word starting with a digit takes the preceding word as well when that word also starts with a digit and does not begin with 194, otherwise a non-digit last word joins the house number when there are more than two words). The street slice and house slice are printed with Put_Line concatenation, printing (none) when no house number exists. About 130 lines.

## Proof obligations to watch

- **index**: Word start/end indexes and the word count are loop-carried, so each is stored in a subtype-ranged array and a guard (count below capacity, word count at least 1 or 2) precedes every use, with an address that has too few words reported as having no house number.
- **length**: The street slice and the concatenated output line are bounded by the 40-character address capacity and fixed output buffers, and over-long addresses are rejected visibly.
- **overflow**: All counters and indexes are ranged subtypes bounded by the address capacity, so the increments are guarded by the capacity test rather than relying on loop invariants.
- **other**: The test set contains non-ASCII characters such as the en dash, the typographic apostrophe and the o with diaeresis, which the program treats as opaque bytes or Latin-1 characters that are never classified as digits, so they only pass through to output.

## Language surface beyond today's Silver

Ranged subtypes, integers, Boolean objects, characters, arrays, records, string indexing, unconstrained arrays, string building, for loops, procedures and functions.

## External effects

- **console output** (allowed): Prints the street and house number for each of the 32 embedded test addresses with Put_Line.

Assessed on 2026-10-15 against page revision 406114 of the [task](https://rosettacode.org/wiki/Separate_the_house_number_from_the_street_name) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
