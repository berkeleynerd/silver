# Return multiple values

**Candidate: proofs likely to discharge automatically.** The only non-trivial checks are the addition and subtraction overflow checks, and the declared range on the parameter subtype discharges them; out parameters are fully assigned, so flow analysis passes.

Position 34 in the [progression](../../progression.md#stage-3), in stage 3, which adds procedures, ranged subtypes and 'Image of scalars.

## Approach

A local procedure Sum_And_Diff takes two in parameters of a bounded integer subtype and returns two results through out parameters of type Integer. Main calls it on embedded constants 5 and 3 and prints both results with Put_Line, using 'Image and concatenation. About 20 lines.

## Proof obligations to watch

- **overflow**: The procedure's in parameters use a declared subtype such as range -1000 .. 1000, so the sum and difference provably fit in Integer without any contract.

## Language surface beyond today's Silver

Integers, ranged subtypes, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the two returned values with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 412999 of the [task](https://rosettacode.org/wiki/Return_multiple_values) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
