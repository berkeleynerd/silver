# Regular expressions

**Candidate: proofs plausibly discharge automatically.** Matching and substitution can be done with a bounded iterative NFA simulation in procedures with explicitly guarded indexes, so every check follows from subtypes and guards, but the loop-carried positions and the matcher's shape make discharge depend on careful structure.

Position 1192 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

The program embeds the subject string "I love PATTERN matching!" and small fixed-capacity patterns (literals, '.', bracket ranges, and the '+', '*', '?' quantifiers) compiled into an array of records, then matches by Thompson-style state-set simulation using Boolean arrays, with no recursion or backtracking. A find-all procedure scans each start position with for loops and a longest-match while loop, printing each word match, and a second procedure builds the substituted string for "PATTERN" into a bounded buffer. Malformed or over-capacity patterns and results that exceed the buffer are rejected with a printed message. About 170 lines.

## Proof obligations to watch

- **index**: Pattern positions, NFA state indexes and subject positions are all bounded subtypes with explicit length guards before each access, and pattern compilation rejects over-capacity or malformed patterns with a visible message.
- **termination**: All scanning is done with for loops over fixed ranges or while loops inside procedures, which get no termination check, and no function contains a while loop.
- **overflow**: Loop-carried match start and end positions are typed as the bounded position subtype and checked against capacity by a guard before each increment.
- **length**: The substituted result is built in a fixed-capacity buffer, and a guard on the combined length reports a visible too-long outcome rather than truncating.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, enumerations, arrays, records, string indexing, string building, case statements, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): Prints each match and the substituted string with Put_Line.

Assessed on 2026-10-15 against page revision 412995 of the [task](https://rosettacode.org/wiki/Regular_expressions) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
