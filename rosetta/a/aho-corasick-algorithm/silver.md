# Aho–Corasick algorithm

**Candidate: proofs plausibly discharge automatically.** All indexes are subtype-ranged node, letter and pattern ids, the only while loop is in a procedure, and propagating match flags per pattern removes any need for output-link chasing, so only careful capacity guards on the counters are needed.

Position 1542 in the [progression](../../progression.md#stage-32), in stage 32.

## Approach

Embed the five patterns and the text as String constants and build a bounded trie in a 2D array Next(Node_Id, Letter_Id) with a Boolean Matches(Node_Id, Pattern_Id) table, rejecting out-of-alphabet characters or exceeding capacity. A procedure runs the BFS with a while loop over a fixed-size queue to fill failure links, complete transitions and propagate Matches along failure links. A for loop over the text steps the automaton, and for each pattern with Matches true it prints the starting position as end position minus pattern length plus one. About 130 lines.

## Proof obligations to watch

- **index**: Trie, transition and queue indexes are all subtypes (Node_Id, Letter_Id, Queue_Pos) so lookups discharge by type, and the node-count and queue-tail increments are each guarded by a visible capacity test that rejects overflow.
- **overflow**: The loop-carried node counter, queue tail and match position are bounded by their ranged subtypes plus guards before each increment, since no invariant can carry the bound.
- **range**: Converting Character'Pos(c)-Character'Pos('a') to a letter index needs an explicit guard rejecting characters outside a..z, with a visible rejection message.
- **termination**: The BFS queue loop is a while loop kept inside a procedure so no termination check applies, and all other loops are for loops.
- **initialization**: Transition, fail and match tables are fully initialized by aggregates or for loops before the BFS reads them.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, unconstrained arrays, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, Put without a newline and membership tests.

## External effects

- **console output** (allowed): Prints each pattern's starting positions in the text abaaabaa.

Assessed on 2026-10-15 against page revision 413631 of the [task](https://rosettacode.org/wiki/Aho%E2%80%93Corasick_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
