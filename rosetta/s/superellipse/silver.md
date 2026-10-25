# Superellipse

**Candidate: proofs plausibly discharge automatically.** Everything is bounded for loops over fixed ranges with no loop-carried accumulators, so only the floating-point power and its finiteness need care, which range-constrained Float operands make plausible rather than certain.

Position 861 in the [progression](../../progression.md#stage-14), in stage 14, which adds floating point.

## Approach

Sample the plane on a fixed integer grid (for example X and Y from -20 to 20 scaled to a=b=200 by a constant factor) with for loops, compute Float (abs(X/A))**2.5 + (abs(Y/B))**2.5 and mark a cell with '*' when it lies within a tolerance band around 1.0, otherwise a space. Each row is a fixed-length String variable filled by index inside the inner for loop over its own range and written with Silver_IO.Put_Line after the inner loop; no loop-carried values exist beyond the row buffer. About 35 lines.

## Proof obligations to watch

- **floating point**: The Float expression (abs(X/A))**2.5 + (abs(Y/B))**2.5 needs bounded operands, which holds because X and Y are loop indexes over a declared small range converted to Float, so results stay finite and within the Elementary_Functions precondition (non-negative base) that abs guarantees.
- **range**: Float-to-integer or text-art cell mapping must stay within the row String bounds, which holds because the column is the for-loop index itself over the String's own range.
- **other**: Whether the provers discharge the Elementary_Functions power contract and finiteness of the sum without help is uncertain, so ranged Float subtypes and a tolerance band test must carry the bounds.

## Language surface recorded by this assessment

Integers, ranged subtypes, floating point, characters, string indexing and for loops.

## External effects

- **console output** (allowed): The superellipse is drawn as text art, one Put_Line per row, which meets the draw-without-display allowance.

Assessed on 2026-10-15 against page revision 414536 of the [task](https://rosettacode.org/wiki/Superellipse) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
