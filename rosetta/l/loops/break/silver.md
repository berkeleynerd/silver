# Loops/Break

**Candidate: proofs likely to discharge automatically.** Every check follows from subtype ranges and a bounded LCG step, and the endless-loop semantics live in a procedure, which gets no termination check. The seeded generator is deterministic, so the "loop forever if 10 never appears" behavior is faithful, though for a fixed seed the run may either stop or cycle forever, which is a visible outcome of the specification.

Position 188 in the [progression](../../../progression.md#stage-7), in stage 7.

## Approach

Keep a deterministic linear congruential generator state in a bounded integer subtype (seeded with a constant) and derive each number as state mod 20 in 0..19. Run a plain loop with exit when in the main procedure: generate A, print it, exit when A = 10, otherwise generate and print B. The state update uses a range-bounded multiply and mod so every intermediate stays within Integer. About 30 lines.

## Proof obligations to watch

- **overflow**: The LCG state is a modular or range-bounded value, so the multiply-and-add is guarded by a bound on the state and cannot overflow.
- **termination**: A procedure's loop gets no termination check, but the program is a main procedure so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints each generated number on its own line.

Assessed on 2026-10-15 against page revision 412890 of the [task](https://rosettacode.org/wiki/Loops/Break) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
