# Approximate equality

**Candidate: proofs likely to discharge automatically.** Every operation works on embedded constants or bounded real subtypes with no loops, so all float overflow and range checks follow from types and literals and no annotation is needed. The only unusual need is Long_Float arithmetic with Sqrt, which is routine once operands are range-bounded.

Position 884 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Define a bounded Long_Float subtype Real, a function Approx_Equal that returns Abs(Left-Right) <= 1.0e-9 * Real'Max(Abs Left, Abs Right) written with plain if statements, and a procedure Check that prints a fixed label and True or False through Put_Line. The main body calls Check for each of the eight embedded pairs, with Sqrt(2.0) from the admitted elementary-functions library; there is no input, loop or recursion. About 45 lines.

## Proof obligations to watch

- **floating point**: The subtraction and the scaling by 1.0e-9 cannot overflow because the operands are a bounded real subtype (about plus or minus 1.0e30), and the Sqrt argument is the literal 2.0, so its non-negativity precondition is trivially met.
- **overflow**: Products such as Sqrt(2.0) * Sqrt(2.0) and the division 10000000000000.001 / 10000.0 involve only constants and a nonzero literal divisor, so the provers bound them directly.

## Language surface beyond today's Silver

Floating point, Boolean objects, functions, procedures and conditional expressions.

## External effects

- **console output** (allowed): Prints each comparison's result line with Put_Line.

Assessed on 2026-10-15 against page revision 415011 of the [task](https://rosettacode.org/wiki/Approximate_equality) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
