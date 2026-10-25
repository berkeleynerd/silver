# Dating agency

**Candidate: proofs likely to discharge automatically.** The scenario is a small fixed-size data model with trivial integer and Character arithmetic over static ranges, and only for loops, so every check follows from types and bounds. It needs no recursion, while loops or heap.

Position 520 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Ten ladies' names are stored as fixed-length (padded) String constants in an array indexed 1..10, with the sailor's name as a constant. Per lady, nice is a Boolean function (digit root of the first character's position greater than 4, via a bounded for-loop digit sum) and lovable is the parity of that position; for loops build Boolean result arrays, then print a table, the suggested ladies, and those the sailor would date (nice and lovable). All arithmetic is on small ranged integers so no guards beyond static bounds are needed. About 70 lines.

## Proof obligations to watch

- **index**: Each name is a fixed-length String padded to a constant width and indexed only at its first character with static bounds, so the access is routine.
- **range**: Digit root of a character position (at most 255) is computed with a for loop over a fixed three-digit decomposition, so every value stays within declared integer ranges.

## Language surface recorded by this assessment

Characters, ranged subtypes, Boolean objects, arrays, for loops, integers, integer division, procedures, functions, string indexing, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the table of ladies, suggested ladies and dates as text lines.

Assessed on 2026-10-15 against page revision 414147 of the [task](https://rosettacode.org/wiki/Dating_agency) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
