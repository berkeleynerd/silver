# Pythagorean quadruples

**Candidate: proofs likely to discharge automatically.** Every check follows from the range-subtyped for-loop indexes and static array bounds with no loop-carried accumulator, so proofs should discharge without annotations. The only mild concern is the nonlinear products, which are bounded by the 1..2200 operand ranges.

Position 90 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Declare a ranged subtype Num 1..2200 and a Boolean array Sums indexed 0..9_680_000; a nested for loop over x and y marks every x*x+y*y. A second nested for loop over d and c in 1..d-1 sets Found(d) when Sums(d*d-c*c) is marked, and a final for loop appends each unmarked d to a bounded output buffer that is printed on one line with Put and Integer'Image. About 45 lines.

## Proof obligations to watch

- **overflow**: x*x+y*y and d*d-c*c are nonlinear but the operands are range-subtyped to 1..2200, so results stay under 9.7 million and fit Integer.
- **index**: Indexes d*d-c*c (with c < d from the inner for-range) and x*x+y*y lie within the array bound 0..9_680_000, which the provers can show from the operand ranges.
- **stack**: A Boolean array of about 9.7 million entries is a fixed-size environmental memory premise, which GNATprove does not check.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the unrepresentable values of d on one line.

Assessed on 2026-10-15 against page revision 413867 of the [task](https://rosettacode.org/wiki/Pythagorean_quadruples) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
