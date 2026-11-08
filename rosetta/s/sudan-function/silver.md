# Sudan function

**Candidate: proofs plausibly discharge automatically.** Evaluating iteratively with an explicit bounded stack inside a procedure avoids recursion and the termination check, and every loop-carried addition and stack index can be guarded just before use with a visible overflow or capacity outcome. Discharge depends on placing those guards carefully rather than on any annotation, so the outlook is plausible.

Position 616 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

A procedure Sudan (N, X, Y; out Value, out Ok) replaces recursion with an explicit stack: an array of frame records (level, running value v, counter k, limit y) bounded by a documented maximum level, where a level-n frame repeatedly computes v := F_{n-1}(v, v + k + 1) for k in 0 .. y - 1 by pushing a child frame and level 0 returns x + y directly. A while loop in the procedure drives push and pop, with guards before every addition, increment, push and pop that end evaluation with Ok = False and an 'overflow' message rather than a wrong value. Main calls it on the task's sample arguments embedded as literals and prints each result with 'Image. About 85 lines.

## Proof obligations to watch

- **overflow**: Sudan values explode (F2(2,2) already exceeds 64 bits), so every x + y and v + k + 1 is preceded by a guard against the type's upper bound that stops evaluation with a visible 'overflow' outcome instead of a value.
- **index**: The explicit frame stack's top index is loop-carried, so each push is guarded by a test that the stack (sized to a documented maximum level) is not full, and each pop by a test that it is non-empty.
- **range**: The loop counter k and level n stored in frames are loop-carried, so increments and decrements are guarded just before use (k < y, n > 0) to stay within their declared subtypes.
- **termination**: The evaluation runs an unbounded number of steps in a while loop, so it is written as a procedure with an out value and status, which GNATprove does not check for termination.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, records, while loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints F_n(x, y) for a few embedded sample arguments with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413071 of the [task](https://rosettacode.org/wiki/Sudan_function) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
