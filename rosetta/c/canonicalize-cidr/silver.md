# Canonicalize CIDR

**Candidate: proofs plausibly discharge automatically.** Every operation is bounded integer arithmetic on small subtypes with guards before each string index and digit accumulation, so no annotation is needed, but the hand-written parser's loop-carried position and value need careful guard placement.

Position 1129 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

The five example CIDR strings are embedded as an array of fixed-length padded Strings, and a procedure parses each into four octets (subtype 0..255) and a mask (subtype 0..32) with digit-by-digit guarded accumulation, reporting invalid text as a rejection line. Canonicalization is done per octet: the number of network bits falling in that octet (0..8) selects a constant divisor table entry, and the octet becomes (octet / d) * d. The result is printed with 'Image-style conversion of each octet and mask joined by dots and a slash. About 110 lines.

## Proof obligations to watch

- **index**: The parser advances a loop-carried position through the padded input string, so every read is preceded by an explicit Pos <= S'Last guard, and failure yields a printed rejection line.
- **overflow**: Octet and mask accumulation of decimal digits is capped by guards (stop after three digits, reject values above 255 or mask above 32) so the loop-carried values stay within their subtype ranges.
- **division**: Masking divides by a power of two taken from a constant table indexed by the bit count 0..8, so the divisor is statically nonzero.
- **termination**: Scanning uses while loops only inside procedures, which get no termination check.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing, 'Image of scalars, text parsing, for loops, while loops, procedures, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): Prints each input CIDR and its canonical form to standard output.

Assessed on 2026-10-15 against page revision 413659 of the [task](https://rosettacode.org/wiki/Canonicalize_CIDR) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
