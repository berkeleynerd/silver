# Random number generator (included)

**Candidate: proofs likely to discharge automatically.** The program uses only constructs Silver already has: String literal output in one parameterless Main with no arithmetic, indexing or loops, so there are no proof obligations beyond trivial ones. The reported text depends on which generator, if any, Silver's library eventually admits, but that changes no proof check.

Position 15 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The task asks only to report which algorithm the language's built-in generator uses, not to implement one, so Main is a short sequence of Silver_IO.Put_Line calls with String literals. They name the algorithm of Silver's admitted generator library (or say that Silver provides none and the task is skipped) and give a link to the wider explanation. There is no data, no loops and nothing that needs a guard. About 10 lines.

## External effects

- **console output** (allowed): The program prints a statement naming the generator algorithm and a link to its explanation with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413876 of the [task](https://rosettacode.org/wiki/Random_number_generator_%28included%29) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
