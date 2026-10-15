# Rep-string

**Candidate: proofs plausibly discharge automatically.** The algorithm is two nested for loops over indexes bounded by the string's own length, so index checks follow from loop ranges and types with no invariants; the plausible rating reflects unconstrained-string index arithmetic and output line construction needing careful guards.

Position 1002 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

A procedure Check takes an unconstrained String, loops I from L/2 down to 1 and inner J from I+1 to L, clearing a Boolean flag when S(J) differs from S(J-I) (offset by S'First), and records the first (longest) unit that matches. Main calls Check on each of the eleven embedded example strings and prints either the longest rep-string or "No rep-string" via Put_Line, building the line from slices with a guarded length. All indexes derive from loop ranges within the string's bounds. About 55 lines.

## Proof obligations to watch

- **index**: Comparing S(J) with S(J-I) in the nested for loops is safe only if J ranges over I+1..L with I at most L/2 and offsets from S'First are derived from a bounded String index subtype, which the loop bounds and types give without invariants.
- **overflow**: Computing S'First + J - 1 and concatenating slices into the output line needs the index subtype and a length guard so nothing exceeds the bounded buffer, which a guard before each Put_Line can supply.
- **termination**: Only for loops are used (a Boolean flag records a mismatch rather than an early exit), so no variant is needed.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, string indexing, unconstrained arrays, for loops, while loops, procedures and string building.

## External effects

- **console output** (allowed): Prints one result line per embedded example string.

Assessed on 2026-10-15 against page revision 414723 of the [task](https://rosettacode.org/wiki/Rep-string) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
