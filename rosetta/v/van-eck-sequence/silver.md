# Van Eck sequence

**Candidate: proofs likely to discharge automatically.** Every check follows from the array's index range and the Term subtype bounds, with only for loops over the array's own range and no recursion, so no annotations are needed. The only surface beyond today's Silver is standard (arrays, ranged subtypes, for loops with exit, procedures, integer image output).

Position 202 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Store the 1000 terms in a constrained array of a subtype Term range 0 .. 1000 indexed 1 .. 1000, set the first term to zero, and for each index scan backward with a reverse for loop that exits at the first match, writing Index - I or leaving the pre-set zero. A procedure Show prints a range of terms with Put and Integer'Image, followed by a line terminator, and the main procedure calls it for 1 .. 10 and 991 .. 1000. About 45 lines.

## Proof obligations to watch

- **overflow**: Index + 1 and Index - I stay in range because the outer loop stops at Last - 1, the inner loop runs below Index, and every term is stored in a subtype 0 .. 1000 that holds the maximum distance of 999.
- **index**: Both loop indexes range over the array's own bounds, so every Sequence access discharges without invariants.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first ten terms and terms 991 to 1000 to standard output.

Assessed on 2026-10-15 against page revision 411835 of the [task](https://rosettacode.org/wiki/Van_Eck_sequence) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
