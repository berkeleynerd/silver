# Szymański's algorithm

**Candidate: proofs plausibly discharge automatically.** The task asks for parallel processes but allows coroutines, so a deterministic interleaved state-machine simulation avoids tasking and every check follows from subtypes, array ranges and bounded for loops. Outlook is plausible rather than likely because the many state transitions and trace string lengths need careful range sizing.

Position 831 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Real tasks are avoided by modelling each of a few processes as a coroutine-like state machine with a program counter and a flag array holding values 0 to 4 from the Wikipedia pseudocode. A procedure advances one process by one pseudocode step via a case on its counter, with the wait conditions evaluated by for loops over all flags, and a for loop over a fixed step budget picks the next process deterministically with a mod-based generator. After each step the program prints a trace line and reports a visible violation line if more than one process is in the critical section. About 120 lines.

## Proof obligations to watch

- **index**: Process and flag indexes are subtypes of the array index range and the scheduler's choice is reduced with mod by the process count, so index checks follow from declared ranges.
- **range**: Each process's program counter and flag value are assigned only literal constants within their subtypes, and counters like entry counts are capped by guards or loop-bounded by the fixed step count.
- **length**: Trace lines concatenate 'Image text of small ranged values into bounded strings, so lengths are statically bounded but need careful sizing.
- **termination**: Interleaving is driven by a for loop over a fixed step budget, so no while loop or variant is needed, though the trace shows only a bounded prefix of execution rather than the algorithm running forever.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, case statements, for loops, procedures, functions, 'Image of scalars and string building.

## External effects

- **console output** (allowed): The program prints each scheduler step's process, state and critical-section occupancy as text lines.

Assessed on 2026-10-15 against page revision 414540 of the [task](https://rosettacode.org/wiki/Szyma%C5%84ski's_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
