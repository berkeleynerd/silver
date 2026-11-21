# Universal Turing machine

**Candidate: proofs likely to discharge automatically.** All indexes and values come from ranged types and bounded tapes with explicit guards before each head move, and the loops live in procedures so no termination check or variant is needed. The only care needed is the guarded head and step counters, which need no annotations.

Position 1171 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

A generic-free procedure Run takes a rules table (2-D array indexed by ranged state and symbol subtypes, each entry a record of new state, movement enum and new symbol) plus a fixed-capacity tape array of ranged symbols with a start head position and a step limit. A while loop in a procedure steps until the halt state, with guards on step count and head bounds that end the run with a printed outcome (halted, step limit, or tape limit); the final tape is rendered into a bounded String via a symbol-to-Character map and printed with a caret line. The incrementer and busy beaver are embedded as constant rule tables and run in sequence; the 47-million-step bonus machine is left out as optional. About 130 lines.

## Proof obligations to watch

- **index**: The head position is loop-carried, so each move is guarded (left only when head is above 1, right only when below the tape capacity) and an off-tape move halts with a visible 'tape limit' outcome.
- **overflow**: The step counter is incremented only inside a loop condition that tests it against a declared maximum, so the increment cannot overflow.

## Language surface recorded by this assessment

Integers, ranged subtypes, enumerations, characters, arrays, multidimensional arrays, records, string building, case statements, for loops, while loops, procedures and Boolean objects.

## External effects

- **console output** (allowed): Prints the final tape and head marker for the incrementer and the three-state busy beaver with Put_Line.

Assessed on 2026-10-15 against page revision 414563 of the [task](https://rosettacode.org/wiki/Universal_Turing_machine) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
