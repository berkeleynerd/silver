# Addition chains

**Candidate: proofs plausibly discharge automatically.** Everything is small bounded arrays and integers with typed ranges, and the loop-carried depth and counters can be bounded by types and guards before use, though the nested DFS shape needs care and no annotation should be required. The extra-credit targets are optional and omitted, so the search stays tiny.

Position 1531 in the [progression](../../progression.md#stage-31), in stage 31.

## Approach

Embed the seven required targets in a constant array and, for each, run iterative deepening on length L with an explicit-stack DFS in a procedure over a fixed array holding the chain. At each depth try each next value from last+1 to min(target, 2*last) that a for-loop pair check shows is a sum of two earlier entries (which de-duplicates chains), prune if doubling cannot reach the target, and classify a completed chain as Brauer when each element is the previous plus an earlier one. The first L with any chain gives L(n), then both counts and one stored example chain of each kind are printed with Image and Put. About 120 lines.

## Proof obligations to watch

- **index**: The explicit-stack depth is a loop-carried value, so every push and pop is guarded by comparing depth with the array bound just before the access, with the iterative-deepening length capped at the array size.
- **overflow**: Chain values are capped by the target (at most 64 in the required set) by an explicit guard before storing and sums stay far below the integer range, while the two counters are range-limited and a guard rejects reaching the limit.
- **termination**: The iterative DFS and deepening loops are while loops confined to procedures, which get no termination check, and the search function uses only for loops.
- **range**: Candidate values and loop-carried indices are typed with bounded subtypes and guarded before each assignment so no range check depends on an invariant.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, Put without a newline, string building and block statements.

## External effects

- **console output** (allowed): Prints L(n), the two counts and an example chain for each target n.

Assessed on 2026-10-15 against page revision 409220 of the [task](https://rosettacode.org/wiki/Addition_chains) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
