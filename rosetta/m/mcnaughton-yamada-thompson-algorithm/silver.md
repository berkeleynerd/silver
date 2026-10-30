# McNaughton-Yamada-Thompson algorithm

**Candidate: proofs plausibly discharge automatically.** Every structure is a fixed-capacity array with guards before each push or pop, so index and range checks follow from types and local guards, but several loop-carried counters across nested procedures need careful shaping, hence plausible rather than likely.

Position 1023 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Index-based arrays replace pointers: a State record array (label Character, edge1, edge2 as State_Index with 0 meaning none, plus an epsilon flag) and a fragment stack of (initial, accept) index pairs, all with fixed capacity. A procedure converts the infix pattern to postfix with a bounded operator stack by precedence, builds the NFA by popping and pushing fragments with capacity and depth guards, then simulates matching with Boolean membership arrays for the current and next state sets and an iterative worklist epsilon closure. The program loops over embedded patterns and test strings, printing True or False for each and an explicit invalid-pattern line when a guard trips. About 260 lines.

## Proof obligations to watch

- **index**: Shunting-yard operator stack, postfix buffer, NFA fragment stack and state table are fixed-capacity, and every push is preceded by a capacity guard that rejects the pattern with a visible message instead of overflowing.
- **index**: Popping operands for '.', '|', '*', '+', '?' is guarded by a stack-depth test, so malformed patterns such as 'a.' or unbalanced parentheses report an invalid pattern.
- **range**: Counters and state indexes carried through while loops are ranged subtypes bumped only after an explicit less-than-capacity check, since without invariants only the type range is known.
- **termination**: The epsilon-closure worklist and the shunting-yard pop loops are while loops inside procedures, which get no termination check, and the closure marks states in a Boolean array so it also terminates in practice.
- **index**: Text and pattern positions use for loops over the String's own 'Range, but the unconstrained String parameters need bounded first/last handling (e.g. Positive-indexed strings) to avoid index overflow arithmetic.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, records, unconstrained arrays, string indexing, string building, case statements, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): Prints a True/False line for each embedded pattern and test string.

Assessed on 2026-10-15 against page revision 412917 of the [task](https://rosettacode.org/wiki/McNaughton-Yamada-Thompson_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
