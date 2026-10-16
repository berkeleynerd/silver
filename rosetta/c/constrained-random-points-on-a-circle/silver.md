# Constrained random points on a circle

**Candidate: proofs likely to discharge automatically.** Using the precalculated pool avoids an unbounded rejection loop, every operand comes from small declared ranges or modular wraparound, and the only loop-carried value (the pool counter) is made safe by a guard placed just before its use, so all checks should discharge without annotations.

Position 1275 in the [progression](../../progression.md#stage-22), in stage 22.

## Approach

A subtype Coordinate covers -15 .. 15, and nested for loops collect every grid point with 100 <= x*x + y*y <= 225 into two fixed arrays of 961 entries; the pool counter is guarded before each increment. A 32-bit modular linear congruential generator then picks 100 pool indexes with 'mod Pool_Count + 1', under a guard that Pool_Count is positive. Each chosen point sets an asterisk in an array of 31 blank 31-character String rows, which are printed with Put_Line. About 55 lines.

## Proof obligations to watch

- **index**: The pool counter carried through the nested precalculation loops is bounded only by its type, so a guard such as 'if Pool_Count < Pool_X'Last' before each increment and store discharges it; the guard never fires because the pool has room for all 961 grid points.
- **division**: The random index uses 'Seed mod U32 (Pool_Count)' inside an 'if Pool_Count > 0' guard, so the divisor is provably nonzero, and the result plus 1 stays within 1 .. Pool_Count.
- **overflow**: x*x + y*y is nonlinear, but with both operands in -15 .. 15 the sum is at most 450, and the generator uses a modular type that wraps by definition, so neither can overflow.

## Language surface recorded by this assessment

Integers, integer division, modular types, ranged subtypes, characters, arrays, string indexing and for loops.

## External effects

- **console output** (allowed): The fuzzy circle is printed as 31 lines of text art, with an asterisk at each chosen point.

Assessed on 2026-10-15 against page revision 415033 of the [task](https://rosettacode.org/wiki/Constrained_random_points_on_a_circle) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
