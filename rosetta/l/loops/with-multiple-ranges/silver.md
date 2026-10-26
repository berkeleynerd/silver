# Loops/With multiple ranges

**Candidate: proofs plausibly discharge automatically.** The program is a handful of simple bounded loops with guarded accumulators, so every check follows from declared ranges and guards just before each operation, though the loop-carried sum and product need careful guards.

Position 239 in the [progression](../../../progression.md#stage-7), in stage 7.

## Approach

Each of the seven ranges is a loop in Main that calls a procedure Accumulate (Sum, Prod in out; J in) in the PL/I order, with while loops for the stepped ranges and for loops for the unit-step ranges, using literal bounds (27, 161051 and so on) so no exponentiation is needed. J, Sum and Prod are Long_Long_Integer-based range subtypes; Accumulate adds abs(J) to Sum behind a cap guard that rejects when exceeded, and multiplies Prod only when abs(Prod) < 2**27 and J /= 0. The two totals are printed with 'Image-based Put_Line, and comma grouping is omitted as optional. About 75 lines.

## Proof obligations to watch

- **overflow**: The sum and product accumulators are loop-carried, so each update sits behind an explicit guard (sum below a stated cap, abs(prod) below 2**27 with every index bounded by a declared range type) that rejects on violation, and both fit in 64 bits.
- **overflow**: Each while-loop index update is guarded by the loop condition, which bounds the index just before the add or subtract, so the step cannot overflow its declared range.
- **termination**: All while loops live in procedures, which get no termination check, and the fixed-step for loops terminate by themselves.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, while loops, for loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): The two totals, sum and prod, are printed with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 411866 of the [task](https://rosettacode.org/wiki/Loops/With_multiple_ranges) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
