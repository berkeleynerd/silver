# Pascal's triangle

**Candidate: proofs likely to discharge automatically.** All loops are for loops over static ranges and every index is a loop variable within the array's bounds, so only the entry sum needs a guard, which is a plain comparison just before the assignment. Negative or zero row counts do not arise because the count is an embedded constant, and no recursion, floating point or annotations are needed.

Position 442 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

The program embeds a fixed row count of 12, keeps one array of entries of a bounded subtype indexed 0 .. 11, and for each row prints entries 1 .. row with Put of their 'Image, then updates the array in place using a reverse for loop. Each new entry is the sum of two old entries computed in Long_Long_Integer and checked against the subtype's limit before assignment, with a visible rejection message otherwise. About 45 lines.

## Proof obligations to watch

- **overflow**: The in-place row update adds two loop-carried entries, so each sum is computed in a wider type and guarded against the entry subtype's limit just before assignment, with overflow leading to a visible rejection message.
- **range**: Entries are a bounded subtype, so the assignment range check discharges only through the explicit guard on the sum, not through any loop invariant.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, 'Image of scalars, Put without a newline, procedures and characters.

## External effects

- **console output** (allowed): The triangle rows are printed to standard output.

Assessed on 2026-10-15 against page revision 414897 of the [task](https://rosettacode.org/wiki/Pascal's_triangle) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
