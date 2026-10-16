# GSTrans string conversion

**Candidate: proofs likely to discharge automatically.** All checks come from ranged subtypes, a capacity guard before each buffer append and for loops in procedures, so no annotations are needed and the recursive encoder in the existing solution becomes simple iteration. Error checking is expressed as an explicit rejection outcome rather than a silently altered result.

Position 805 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Strings are fixed-capacity Character arrays with an explicit length held in a ranged subtype. Encode is a procedure that loops over the input and appends one to four characters per byte using a case on the byte class, with a capacity guard before each append. Decode is a procedure with a for loop and a small state (after bar, after bang) that reports a Boolean success flag and rejects malformed input such as a trailing bar or an unknown escape; the main program embeds the example strings, round-trips them and prints the results. About 130 lines.

## Proof obligations to watch

- **index**: Appends to the fixed-capacity output buffer are discharged by a guard that rejects with an overflow outcome when fewer than four free slots remain, and the length is a ranged subtype so it is bounded across loop iterations.
- **range**: Character arithmetic such as 'Pos(C) - 128 + 64 is guarded by explicit range tests on the code before each 'Val conversion, so each result stays within 0..255.
- **termination**: Only for loops and a small state machine inside procedures are used, so no variant is needed.

## Language surface recorded by this assessment

Characters, ranged subtypes, integers, Boolean objects, arrays, for loops, procedures, case statements, string indexing, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each test string's encoded form, decoded form, round-trip result and any decode error.

Assessed on 2026-10-15 against page revision 413729 of the [task](https://rosettacode.org/wiki/GSTrans_string_conversion) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
