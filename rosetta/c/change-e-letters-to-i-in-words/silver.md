# Change e letters to i in words

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed array bounds, range-typed indexes and explicit capacity guards, with the loops in procedures so no variant is needed, but it needs file input, string slicing and ordering that Silver lacks and careful guards on the search indexes.

Position 1476 in the [progression](../../progression.md#stage-28), in stage 28.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

The program reads unixdict.txt line by line into a fixed-capacity array of padded 32-character words with a length array, rejecting input that exceeds the word count or word length capacity. For each word of length at least 6, a for loop builds a copy with each e or E replaced by i or I, and if it differs from the original, a binary search procedure over the sorted dictionary (guarded Low/High range types) reports whether the copy is present and the pair is printed with Put_Line. About 110 lines.

## Proof obligations to watch

- **index**: Words are stored in a fixed-capacity array of fixed-length padded strings with a length array, and a guard rejects the input when the word count or a word length exceeds the capacity before each store.
- **overflow**: The word count and binary-search bounds are range-typed subtypes bounded by the capacity, with a guard before each decrement so the midpoint arithmetic and Mid-1 cannot leave their range.
- **termination**: The reading loop and the binary search are while loops placed in procedures, which get no termination check, and the per-word translation uses for loops.
- **length**: Translated words are built in a bounded buffer whose length is checked against the stored word length before comparison, so slices stay within bounds.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, unconstrained arrays, string indexing, string building, string ordering, for loops, while loops, procedures, functions, Boolean objects, file input, Put without a newline and exit status.

## External effects

- **files** (allowed): The dictionary unixdict.txt (about 25,000 words) is too large to embed, so the program must read it line by line from a named file.
- **console output** (allowed): Each qualifying pair is printed as a line of text.
- **arguments** (allowed): The dictionary path is taken from the first command-line argument, with a default of unixdict.txt.
- **exit status** (allowed): A missing, oversized or over-capacity dictionary is rejected with a specified failure status.

Assessed on 2026-10-15 against page revision 406141 of the [task](https://rosettacode.org/wiki/Change_e_letters_to_i_in_words) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
