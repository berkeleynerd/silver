# Towers of Hanoi

**Candidate: proofs likely to discharge automatically.** This is a tiny recursive procedure whose only checks are a guarded decrement and concatenation of bounded image text, and procedures get no termination check, so proofs should discharge; the one soft spot is recursion depth, which the declared subtype bounds.

Position 1551 in the [progression](../../progression.md#stage-34), in stage 34, which adds recursive procedures.

## Approach

Declare a three-value Pegs enumeration and a Disk_Count subtype of Natural with a small fixed maximum, then a recursive procedure Hanoi that, when Ndisks > 0, recurses with Ndisks - 1, prints one move line built from the disk number image and the peg images, and recurses again with the pegs permuted. Main calls Hanoi (4, Left, Right, Center); all arguments are statically in range and the only subtraction sits under the Ndisks > 0 guard. About 22 lines.

## Proof obligations to watch

- **stack**: The task requires recursion, but depth is capped by a declared subtype range on the disk count and Main uses 4 disks, so depth is a small fixed constant within the fixed-memory premise.
- **range**: The Ndisks - 1 subtraction in each recursive call is guarded by the enclosing Ndisks > 0 test, so it discharges from the subtype range.

## Language surface recorded by this assessment

Enumerations, ranged subtypes, integers, 'Image of scalars, procedures, recursive procedures and string building.

## External effects

- **console output** (allowed): Each move is printed with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415536 of the [task](https://rosettacode.org/wiki/Towers_of_Hanoi) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
