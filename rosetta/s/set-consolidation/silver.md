# Set consolidation

**Candidate: proofs plausibly discharge automatically.** All checks follow from fixed-capacity arrays, small ranged subtypes and for-loop indexes, and the non-structural fixpoint is placed in a procedure or bounded by a pass count so nothing needs an annotation. Nested loops with loop-carried counts and merge bookkeeping need careful shape, hence plausible rather than likely.

Position 1191 in the [progression](../../progression.md#stage-20), in stage 20.

## Approach

Represent an element as a Character subtype 'A'..'K' and a set as a Boolean array over it. Keep a fixed-capacity array of sets with an Alive flag per slot. A procedure repeats a bounded number of passes over all slot pairs, merging a pair via a for loop that ORs membership when the two share an element, then a procedure prints each live set in order with Put. Examples are embedded as literal aggregates and no recursion is used. About 110 lines.

## Proof obligations to watch

- **termination**: The merge-until-stable fixpoint loop is a while loop kept inside a procedure (no termination check), or restructured as a bounded for loop of at most N passes, so no variant is needed.
- **index**: Set membership is a Boolean array indexed by an enumeration or 'A'..'K' subtype and sets are stored in a fixed-capacity array indexed by a bounded count, so indices are bounded by types and guards before each use.
- **overflow**: The live-set count and write cursors are loop-carried values in a small ranged subtype and are guarded before each increment to stay within the fixed capacity.

## Language surface beyond today's Silver

Ranged subtypes, enumerations, Boolean objects, arrays, multidimensional arrays, records, for loops, while loops, procedures, functions, Put without a newline, 'Image of scalars, integers, characters and string building.

## External effects

- **console output** (allowed): Prints the consolidated sets for the four embedded examples.

Assessed on 2026-10-15 against page revision 414463 of the [task](https://rosettacode.org/wiki/Set_consolidation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
