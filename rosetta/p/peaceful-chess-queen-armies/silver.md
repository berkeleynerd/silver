# Peaceful chess queen armies

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer and array work in a procedure with an explicit stack, so index and range checks follow from ranged subtypes and guards before each access, with no recursion, heap or annotation needed. The risk is the loop-carried stack depth and cell indices in the backtracking while loop, which need careful guarding but no invariant.

Position 733 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Fixed-capacity arrays hold the queen positions (row and column, 0..8) and the colour of each, with an explicit stack depth replacing recursion; an iterative backtracking procedure places white queens first then black queens, scanning earlier queens of the other colour with a function that tests same row, column or diagonal, and advancing cell candidates monotonically. Inputs (n, m) are embedded constants for the required cases within declared limits (n at most 9, m at most 13), and each solved board is rendered into a String row buffer of characters W, B and dots and printed with Put_Line. If the search exhausts all candidates at depth zero it prints a specified no-solution line. About 150 lines.

## Proof obligations to watch

- **index**: The explicit backtracking stack depth and candidate cell are loop-carried in a while loop, so each use sits behind a guard against the declared maximum (2*m_max entries, cells 0..80) before indexing.
- **overflow**: Position, depth and row/column counters are ranged subtypes incremented only after a bound test, so the additions stay within range.
- **termination**: The iterative search loop lives in a procedure, so there is no termination check, and the search is bounded because each candidate cell index only increases.
- **index**: Row and column come from cell/n and cell mod n with n at least 1 and at most 9, and attack tests use abs of differences of values bounded to 0..8, so there are no division or overflow issues.
- **other**: The m=13, n=9 stretch case is an exhaustive search that may take long at run time, which is not a proof matter but requires a documented iteration-free capacity bound.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, for loops, while loops, procedures, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each board as rows of text characters, plus a no-solution line for the m=10, n=8 case.

Assessed on 2026-10-15 against page revision 414604 of the [task](https://rosettacode.org/wiki/Peaceful_chess_queen_armies) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
