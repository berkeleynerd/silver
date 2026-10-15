# Eertree

**Candidate: proofs plausibly discharge automatically.** Every check follows from small declared ranges and a guard before each text index, and the only unbounded loop is a while loop in a procedure, so no annotation is needed, but the tree-building shape with loop-carried node numbers and the capacity guard needs care.

Position 707 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

The string "eertree" is a constant; node tables (length, suffix link, start position, and a 2D next-edge table indexed by node and letter) are fixed arrays of capacity length+2 with the two roots at nodes 0 and 1. A procedure Add_Char runs a while loop over suffix links with an explicit bounds guard, then creates or reuses the child node and sets its link; the main body loops over positions with a for loop. Output iterates over all nodes, printing each node's palindrome slice with Put and Put_Line, which gives every distinct sub-palindrome once. About 90 lines.

## Proof obligations to watch

- **index**: The suffix-link walk reads text at pos - len - 1, so a guard pos - len - 1 >= 1 is tested just before each read (using and then) and all node numbers are declared in a bounded subtype.
- **range**: Loop-carried node numbers and lengths are stored in arrays whose element subtypes bound them (nodes 0..9, lengths -1..7), so assignments within the walk discharge from types, though the new node count needs an explicit capacity guard.
- **termination**: The suffix-link while loop lives in a procedure, which gets no termination check, so no variant is needed.
- **initialization**: The node tables (length, link, next edges) are fully initialized by aggregates with others so flow analysis sees every element defined.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, string building, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The distinct sub-palindromes are printed to standard output.

Assessed on 2026-10-15 against page revision 414174 of the [task](https://rosettacode.org/wiki/Eertree) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
