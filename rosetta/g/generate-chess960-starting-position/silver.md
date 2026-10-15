# Generate Chess960 starting position

**Candidate: proofs likely to discharge automatically.** Every check follows from bounded range subtypes, fixed array bounds and for loops over the array range, with no recursion or while loops needed, so proofs should discharge without annotations. The only mild care is the LCG product bound and the free-square index search.

Position 531 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Keep the first rank in an 8-element Character array initialised to blanks, and advance a deterministic LCG with an embedded seed whose state is a bounded range subtype. A procedure places a piece in the k-th free square, found by a for loop with a bounded counter; place the two bishops on random light and dark squares (4 choices each), then queen (6 free), knights (5 and 4 free), and fill the last three free squares left to right with R, K, R. Copy the array into an 8-character String with a for loop and print it with Put_Line. About 70 lines.

## Proof obligations to watch

- **overflow**: The LCG product is discharged by declaring the state as a range subtype below 2**31 and a 64-bit base type, so the multiplication cannot overflow.
- **index**: Choosing the k-th free square uses a for loop over the board's own range and a guard that the found position is within 0..7 before writing, with the draw reduced by mod to a count of free squares.
- **division**: mod uses constant nonzero divisors, or a free-square count guarded to be positive, so division by zero cannot occur.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the first rank as a line of letters such as RNBQKBNR.

Assessed on 2026-10-15 against page revision 415504 of the [task](https://rosettacode.org/wiki/Generate_Chess960_starting_position) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
