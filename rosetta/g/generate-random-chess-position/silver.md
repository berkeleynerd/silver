# Generate random chess position

**Candidate: proofs plausibly discharge automatically.** Every array index and arithmetic result is bounded by ranged subtypes, mod reductions and a capacity-bounded buffer, and the only unbounded loops are while loops in procedures, so no annotation is needed, though the LCG arithmetic and buffer-length tracking need careful shaping.

Position 710 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

An 8x8 Character board array is cleared, a deterministic LCG with a fixed seed (state in a bounded integer range, reduced by mod) picks king squares by rejection sampling until they are non-adjacent, then places a random count of pieces from fixed piece strings on empty squares, rejecting rank-8 and rank-1 squares for pawns, with the total capped at 32. A procedure then scans rows, counting empties and appending digits, pieces and slashes into a fixed-length buffer, appends " w - - 0 1", and prints it with Put_Line. About 95 lines.

## Proof obligations to watch

- **overflow**: The linear congruential generator multiplies a state by a large constant, so the state type is a bounded range sized so the product fits in 64 bits and the mod reduces it back, which needs range-bounded nonlinear reasoning but no annotation.
- **termination**: Rejection-sampling loops for king and piece placement are while loops inside procedures, which get no termination check, so they discharge without a variant.
- **index**: Row and column values come from the generator reduced by mod 8 into 0..7 subtypes, and the FEN buffer index is guarded by capacity because at most 64 squares plus 8 separators plus the suffix fit in a fixed 80-character buffer.
- **range**: Empty-square run counts in 0..8 are converted to digit characters with a guard-free 'Val on a bounded subtype, and the adjacent-kings test uses abs differences of 0..7 values that cannot overflow.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, string building, for loops, while loops, procedures, functions, Boolean objects and Put without a newline.

## External effects

- **console output** (allowed): The program prints the FEN string (and optionally a text board) to standard output.

Assessed on 2026-10-15 against page revision 414233 of the [task](https://rosettacode.org/wiki/Generate_random_chess_position) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
