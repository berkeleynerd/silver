# Euclid-Mullin sequence

**Candidate: proofs plausibly discharge automatically.** Every term fits within 46 bits, so a modular product by double-and-add keeps all intermediates inside declared ranges and no annotation is needed; trial division up to about 3.9e13 is far too slow to run in practice but that is a runtime cost, not a proof obstacle.

Position 232 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Store the elements in a constrained array of a residue subtype 0..2**46 (all 27 known terms are below 3.1e13), and for each new element scan odd candidates k from 3 upward in a procedure while loop, computing (product of earlier elements + 1) mod k with a double-and-add multiply-mod helper over a for loop. The first k whose residue is zero is stored and printed with 'Image; a guard on reaching the type limit prints a rejection message instead of continuing. About 70 lines.

## Proof obligations to watch

- **overflow**: Products of residues up to 2**46 overflow 64 bits, so the program uses a double-and-add multiply-mod over a for loop where each loop-carried residue is typed 0..2**46 and doubling stays below 2**48, which discharges from types alone.
- **range**: Assigning the result of 'mod k' back to the residue subtype needs k within the subtype range, which holds because the candidate counter is typed with the same upper limit and a guard exits when it would exceed it with a visible failure message.
- **termination**: The candidate search is a while loop inside a procedure, which gets no termination check, with a bounded candidate type giving an explicit visible outcome if no factor is found below the limit.
- **index**: The element array is indexed by for-loop variables over its own range, so index checks are routine.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each of the 16 (or 27 with the stretch goal) sequence elements on its own line.

Assessed on 2026-10-15 against page revision 414188 of the [task](https://rosettacode.org/wiki/Euclid-Mullin_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
