# De Bruijn sequences

**Candidate: proofs plausibly discharge automatically.** All array indexes, character conversions and window arithmetic follow from subtype ranges and for-loop indexes over fixed buffers, and no recursion, while loop in a function or annotation is needed. The only care needed is bounding the occurrence counters and giving the greedy generator a visible failure branch, hence plausible rather than likely.

Position 571 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Generate B(10,4) with the greedy prefer-largest method: start from four zeros and, for each of the remaining 9996 positions in a for loop, try digits 9 down to 0 and take the first whose 4-digit window is unmarked in a Boolean array of 10000, tracking the window as a bounded integer, then append the first 3 digits to wrap around. A Validate procedure counts every 4-character window of a fixed 10003-character buffer (skipping the period) into a bounded count array and prints missing or duplicated PINs with zero-padded digits; it is called on the original, the reversed copy and the copy with position 4444 replaced by a period. About 120 lines.

## Proof obligations to watch

- **index**: The rolling window value is kept as a 0..9999 subtype computed as (cur mod 1000)*10 + digit, so the table index is bounded by types, and the sequence position is a for-loop index over the buffer's own range.
- **range**: Occurrence counters are capped by a guard before incrementing, with an explicit saturation or reject outcome rather than a silent change to results.
- **termination**: Only for loops and procedures are used, so no variant is needed; the greedy generation uses a fixed iteration count and a visible failure outcome if no unused digit is found.
- **other**: Correctness of the greedy generator (always finding an unused digit) cannot be proved, so the generator must end in an explicit reject branch, which keeps the run-time-error proofs independent of it.
- **overflow**: The mod/multiply window arithmetic is nonlinear but its operands are bounded by subtype ranges, so results stay within 0..9999.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, 'Image of scalars, for loops, procedures, Boolean objects and Put without a newline.

## External effects

- **console output** (allowed): Prints the length, the first and last 130 digits, and the verification results for the three sequences.

Assessed on 2026-10-15 against page revision 413683 of the [task](https://rosettacode.org/wiki/De_Bruijn_sequences) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
