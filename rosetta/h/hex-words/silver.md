# Hex words

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded buffers, small ranged subtypes and explicit guards with visible rejection outcomes, and no function needs a loop variant because the loops live in procedures. The main care points are the guarded value accumulator and the fixed-capacity tables and sorts.

Position 1340 in the [progression](../../progression.md#stage-23), in stage 23.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

Read unixdict.txt line by line in a procedure into a bounded 32-character buffer; for each line of 4 or more characters, check that every character is in 'a'..'f' (lower-casing first), compute the value with a guarded accumulator, the root with the closed form, and the distinct count with a six-entry Boolean array, then store records in fixed-capacity arrays. Two insertion sorts (by root then word, and by descending value) run in procedures with while loops and index guards, followed by padded output using 'Image and string concatenation, plus the two totals. About 170 lines.

## Proof obligations to watch

- **overflow**: The value accumulator V := V*16 + D is loop-carried, so a guard just before it rejects the line when V would exceed a 64-bit bound, which never triggers for words of 15 digits or fewer.
- **index**: Each line is read into a bounded buffer and the result tables have fixed capacity, so over-long lines and table overflow are rejected with a visible message via guards before each store.
- **range**: The distinct-letter counter and the sort positions are loop-carried, so they use small ranged subtypes with a guard before each increment, and insertion sort uses explicit index guards in a while loop.
- **termination**: The insertion-sort and read loops are while loops inside procedures, which get no termination check, so no variant is needed.
- **other**: The digital root uses the closed form 1 + (V - 1) mod 9 for V > 0 so no recursion or digit loop is required.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, functions, file input and Put without a newline.

## External effects

- **files** (allowed): The program reads the dictionary file unixdict.txt line by line, with a specified outcome if it is missing or unreadable.
- **console output** (allowed): The sorted word tables and the two totals are printed to standard output.

Assessed on 2026-10-15 against page revision 413742 of the [task](https://rosettacode.org/wiki/Hex_words) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
