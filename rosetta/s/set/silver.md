# Set

**Candidate: proofs likely to discharge automatically.** Every check is an array index within the subtype's own range or a for-loop over that range, with no loop-carried arithmetic beyond a bounded output-length counter that is guarded, so proofs should discharge without annotations.

Position 894 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

A set is a Boolean membership array indexed by a bounded Character subtype (for example 'a'..'z'), with functions for creation from a literal string, membership, union, intersection, difference, subset and equality, each a for loop over the array's own range. Embedded example sets are built from fixed String literals (using a guard so characters outside the domain are skipped or the input rejected visibly), and a procedure renders each set into a bounded fixed-length String buffer that is printed with Put_Line, along with Boolean results as text. A mutable set demo adds and removes elements by assigning array components. About 90 lines.

## Language surface recorded by this assessment

Boolean objects, characters, ranged subtypes, arrays, for loops, procedures, functions, string building, Put without a newline, integers, string indexing and conditional expressions.

## External effects

- **console output** (allowed): Prints each set and the results of each operation with Put_Line.

Assessed on 2026-10-15 against page revision 414462 of the [task](https://rosettacode.org/wiki/Set) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
