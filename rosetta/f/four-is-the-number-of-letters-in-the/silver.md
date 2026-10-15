# Four is the number of letters in the ...

**Candidate: proofs plausibly discharge automatically.** Everything is integer arithmetic, constant tables and procedure loops whose indexes and accumulators can be bounded by declared ranges and capacity guards, so no annotation is needed, but the large loop-carried totals and big array make careful shape and range types necessary.

Position 583 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Constant tables of padded name strings with lengths hold the small numbers, tens and scale words, and an iterative procedure spells any value up to a declared bound (cardinal or ordinal) into a bounded buffer. A generator procedure appends words in the pattern count-word, 'in', 'the', ordinal-with-comma while recording each word's letter count in a fixed-capacity array and accumulating the total length, stopping at the requested N. The driver runs the 201-word table and the 1,000 to 1,000,000 word cases, printing counts with 'Image and the Nth word from the last-built buffer. About 260 lines.

## Proof obligations to watch

- **index**: Appends into the letter-count array and the bounded word buffer are guarded by explicit capacity checks, with overflow of capacity leading to a visible rejection.
- **overflow**: The loop-carried total character count and word counter are held in a range type sized for 10,000,000 words (about 71 million characters) and guarded before each addition, since no invariant can bound them.
- **termination**: The sentence-generation loop is a while loop kept inside a procedure so it has no termination check, and the number-spelling is an iterative three-digit-group loop rather than recursion.
- **stack**: Storing letter counts for millions of words needs a large array, which GNATprove does not check for stack exhaustion, so it rests on the fixed memory premise and is sized to the 1,000,000-word test (10,000,000 is optional).
- **range**: Number-to-English spelling splits values into groups with div/mod by constants and indexes constant name tables, which discharges from the declared value range of at most 10^9.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the 201 sequence numbers, the Nth word with its letter count and the total sentence length for each test case.

Assessed on 2026-10-15 against page revision 413990 of the [task](https://rosettacode.org/wiki/Four_is_the_number_of_letters_in_the_...) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
