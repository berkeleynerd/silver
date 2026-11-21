# Nonoblock

**Candidate: proofs plausibly discharge automatically.** All checks follow from small ranged subtypes, fixed bounds and guards before each use, but the odometer loop carries several positions with no invariant, so discharge depends on careful guard placement. No recursion or annotation is needed since the enumeration is iterative inside procedures.

Position 568 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Embed the five cases as constant arrays (block lengths, up to 4 entries, plus a count and row width up to 15), and one procedure per case that first checks minimum length (sum plus gaps) against the width and prints No solution if it does not fit. Otherwise it enumerates start positions iteratively with an odometer-style while loop in a procedure, where each block's start is bounded by the previous block's end plus one and by the width minus the minimum length of the remaining blocks. Each valid placement is drawn into a bounded 15-character String of '#' and '.' and printed with Put_Line, then a count line uses 'Image. About 120 lines.

## Proof obligations to watch

- **overflow**: The start positions and running sums are carried through while loops with no invariant, so they are declared as small ranged subtypes (0..16) and guarded before each addition to stay in range.
- **index**: Row-drawing indexes derive from start plus block length, so each is guarded against the row length before writing into the 15-character buffer.
- **termination**: The odometer enumeration uses a while loop, which is acceptable only because it sits in a procedure that gets no termination check.
- **range**: The count of positions is bounded by a declared cap of the largest required answer (15 rows) and a visible overflow-reject outcome if exceeded, rather than silently truncating.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, for loops, while loops, procedures, string indexing, string building and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each header, every block-position row, the position count, and the no-solution message via Put_Line.

Assessed on 2026-10-15 against page revision 414359 of the [task](https://rosettacode.org/wiki/Nonoblock) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
