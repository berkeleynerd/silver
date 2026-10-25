# Variables

**Candidate: proofs likely to discharge automatically.** All values are literals or small sums of literals in straight-line code with no loops, so initialization, data flow and overflow checks discharge directly from constant propagation.

Position 1527 in the [progression](../../progression.md#stage-31), in stage 31.

## Approach

Main declares an Integer constant, initialized Integer, Boolean, Character and fixed-length String variables, assigns new literal or small computed values, and prints each with 'Image or direct String output. A declare block redeclares a name to show hiding and scope, and a local procedure with an in out Integer parameter shows referencing by updating the caller's variable. All arithmetic uses small literals, so every check is static. About 45 lines.

## Language surface recorded by this assessment

Integers, Boolean objects, characters, 'Image of scalars, block statements and procedures.

## External effects

- **console output** (allowed): The program prints the values of its variables after declaration, initialization, assignment and in nested scopes with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413113 of the [task](https://rosettacode.org/wiki/Variables) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
