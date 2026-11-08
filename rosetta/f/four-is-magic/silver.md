# Four is magic

**Candidate: proofs plausibly discharge automatically.** Every check comes from a range-typed number split by div and mod and from guards before appends to a bounded buffer, with the only loop-carried state being the buffer position and the current number, so discharge depends on program shape but needs no annotation. No recursion, heap or function-side loops are needed, because the iteration lives in procedures.

Position 574 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The program keeps constant tables of number words (0..19, tens, thousand) padded to a fixed width with a parallel length table, and a procedure that appends the cardinal text of a number in 0..999999 to a bounded buffer with a fill position. A second procedure loops while the number is not four, appending the number's words, " is ", the count word, and ", ", and finishes with "four is magic."; a guard before each append rejects overflow of the fixed buffer. The main procedure runs this for an embedded list of about ten sample values and prints each line with Put_Line. About 170 lines.

## Proof obligations to watch

- **index**: Word-table lookups use values from div and mod of a number subtype bounded to 0..999999, so each index range follows from the type, with a guard before each table access.
- **length**: The output buffer fill position is loop-carried, so a guard before every append rejects the case where the text would exceed the fixed capacity, which real inputs never reach.
- **overflow**: The count of letters is bounded by the Length of a bounded text buffer subtype, so the next number stays inside the 0..999999 range type without nonlinear arithmetic.
- **termination**: The loop that runs until the number is four sits in a procedure, so there is no termination check, and a fixed iteration cap with a visible reject outcome also bounds it.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, string indexing, string building, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): Each demonstration sequence is printed as a line with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 414221 of the [task](https://rosettacode.org/wiki/Four_is_magic) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
