# Logical operations

**Candidate: proofs likely to discharge automatically.** The only checks are Bronze-level initialization and data flow of two in-mode Boolean parameters; Boolean operators and literal output cannot raise a run-time error, so everything discharges trivially.

Position 94 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A nested procedure Print_Logic (A, B : in Boolean) evaluates A and B, A or B, A xor B and not A, and for each one an if/else chooses between two fixed String literals such as "A and B is TRUE" and "A and B is FALSE" to pass to Put_Line. Main calls Print_Logic four times with the embedded literal pairs (True, True), (True, False), (False, True) and (False, False), first printing a header line for each pair the same way. About 45 lines.

## Language surface beyond today's Silver

Boolean objects and procedures.

## External effects

- **console output** (allowed): The results of and, or, xor and not are printed with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 412885 of the [task](https://rosettacode.org/wiki/Logical_operations) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
