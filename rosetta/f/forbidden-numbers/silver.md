# Forbidden numbers

**Candidate: proofs likely to discharge automatically.** Every operation is bounded integer arithmetic inside for loops with static ranges, and the only loop-carried value is a counter that a visible guard keeps in range, so no annotation is needed. The 4^a(8b+7) characterisation avoids searching sums of squares and keeps all work linear and bounded.

Position 339 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

An Is_Forbidden function takes a Positive number up to 500_000, strips factors of 4 in a for loop of ten iterations (4^10 exceeds 500_000, so no while loop or variant is needed), then tests whether the remainder mod 8 equals 7. The main procedure loops i from 1 to 500_000, keeps a guarded range-typed counter, prints the first fifty with Put in rows of ten, and prints the count at 500, 5_000, 50_000 and 500_000 with Put_Line. About 55 lines.

## Proof obligations to watch

- **overflow**: The running forbidden-number count is loop-carried and known only by its type, so it is declared as a range of 0 .. 500_000 and incremented under an explicit if count is below the limit guard, which cannot trigger because the loop bound is also 500_000.
- **length**: Building each output line from 'Image text of the numbers uses bounded concatenation whose lengths follow from the declared integer ranges, so the buffer size is fixed statically.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first fifty forbidden numbers and the counts up to 500, 5,000, 50,000 and 500,000 as text lines.

Assessed on 2026-10-15 against page revision 413726 of the [task](https://rosettacode.org/wiki/Forbidden_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
