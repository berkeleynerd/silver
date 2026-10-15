# Taxicab numbers

**Candidate: proofs likely to discharge automatically.** All loops are for loops over array ranges and all values are bounded by subtypes, so every check follows from types and static bounds with no invariants. The only effort is writing the sort and scan with the I+1 index guarded by loop ranges.

Position 80 in the [progression](../../progression.md#stage-5), in stage 5.

## Approach

Enumerate all pairs 1 <= X <= Y <= 74 into fixed arrays of 2775 sums with their X and Y, since 74 cubed exceeds the 25th taxicab number 402597 and so the search is complete for it. Sort the entries by sum with a nested for-loop exchange sort in a procedure, then scan adjacent entries with for loops, and print each pair of equal sums as one text line using Integer'Image and concatenation, stopping after 25 matches. The extra-credit 2000th number is treated as optional and omitted. About 75 lines.

## Proof obligations to watch

- **index**: The sort swap and the adjacent-sum scan read element I+1, discharged by for-loop ranges stopping one short of the array's last index.
- **overflow**: Cubes and sums stay below 405224 because the operands are a subtype 1..74, so the nonlinear product is bounded by the type alone.
- **length**: Each output line is a bounded concatenation of 'Image strings whose maximum widths are static, so the result length fits the declared buffer or Put_Line argument.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 25 taxicab numbers with their cubes as text lines.

Assessed on 2026-10-15 against page revision 413081 of the [task](https://rosettacode.org/wiki/Taxicab_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
