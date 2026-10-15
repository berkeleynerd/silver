# Remote agent/Simulation

**Candidate: proofs plausibly discharge automatically.** Everything is bounded-grid indexing, small enums and a ranged LCG with guards before each use, so nothing needs an annotation, but the number of guarded loop-carried values and the stream handling make discharge depend on careful program shape. The task is underspecified, so a stdin/stdout stream is a faithful reading with no Oracle conflict.

Position 1256 in the [progression](../../../progression.md#stage-21), in stage 21.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The program holds a fixed 12 by 12 grid of records (sector colour, ball) and an agent record (position, direction enumeration, carried ball, turn count) with a seeded LCG generating colours, walls and balls using bounded attempt loops. A while loop in a procedure reads one command character at a time from standard input, uses a case statement to apply forward, left, right, get or drop with guarded moves, and prints the response string followed by the end marker. Unknown commands print a rejection response and end of input terminates the loop with a specified status. About 230 lines.

## Proof obligations to watch

- **overflow**: The deterministic pseudo-random generator keeps its state in a bounded range type and reduces it with mod before each multiply so the product cannot overflow.
- **index**: Grid indexes are ranged subtypes and each forward move is guarded by an explicit bounds test on the new position before indexing the grid.
- **termination**: Wall and ball placement use for loops with a bounded number of attempts instead of retry-until-valid loops, so the map generator needs no variant and the command loop lives in a procedure.
- **other**: Unknown command characters and end of input must yield a specified outcome such as a visible rejection response rather than being ignored, per the Oracle.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, records, string indexing, case statements, for loops, while loops, procedures, functions, Put without a newline, standard input and conditional expressions.

## External effects

- **standard input** (allowed): The agent's commands arrive as characters read from standard input, which serves as the unbuffered command stream.
- **console output** (allowed): Responses terminated by the end marker are written to standard output, flushed per command, as the stream back to the agent.

Assessed on 2026-10-15 against page revision 381253 of the [task](https://rosettacode.org/wiki/Remote_agent/Simulation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
