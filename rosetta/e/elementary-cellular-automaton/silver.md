# Elementary cellular automaton

**Candidate: proofs likely to discharge automatically.** Every index and arithmetic operation is bounded by static array ranges, a 0..255 subtype and for loops, so the checks discharge from types and local guards without any annotation. The only new surface is arrays, for loops, string indexing and procedures, and the fixed width and generation count are documented resource limits.

Position 520 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

A procedure Show takes a Rule subtype 0..255 and decodes it into a Boolean array of 8 entries by repeated mod 2 and /2 in a for loop. The state is a fixed-width Boolean array (Width a constant of 21) with a single central cell set, and each of a fixed number of generations (a for loop) writes a new array using if-guarded left and right neighbor indexes, then renders the state into a fixed-length String buffer by indexed Character assignment and prints it. The main procedure calls Show for rules 90, 30 and 122 with literal header lines. About 70 lines.

## Proof obligations to watch

- **index**: Wraparound neighbors are computed with explicit if guards (index 0 maps to Width-1, index Width-1 maps to 0) and the rule table is indexed by a value built from Booleans that is statically within 0..7.
- **range**: The rule number is a subtype 0..255 and the remaining-bits variable keeps that subtype under repeated division by 2, so no loop invariant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, for loops and procedures.

## External effects

- **console output** (allowed): Each generation is printed as a line of '.' and '#' characters with Put_Line.

Assessed on 2026-10-15 against page revision 414941 of the [task](https://rosettacode.org/wiki/Elementary_cellular_automaton) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
