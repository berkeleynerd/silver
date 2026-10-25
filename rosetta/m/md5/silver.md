# MD5

**Candidate: proofs plausibly discharge automatically.** Every operation is bounded fixed-width modular arithmetic with for loops over constant ranges, so checks follow from types and the capacity guard, but the index and conversion plumbing needs careful shape.

Position 1304 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Implement MD5 from scratch with a 32-bit modular word type, constant arrays for the 64 sine-derived constants and shift amounts, and a fixed-capacity byte buffer (for example 192 bytes) holding the message plus RFC 1321 padding and bit length. A procedure loops over 64-byte blocks and 64 rounds with for loops, using a left-rotate built from shifts and mod arithmetic, then hex-formats the four state words through a lookup string into a 32-character buffer printed with Put_Line for the embedded RFC test strings; messages longer than capacity are rejected with a visible message. About 150 lines.

## Proof obligations to watch

- **index**: Padded-buffer and message-word indexes (block*64+j, (5*i+1) mod 16) are discharged by ranged subtypes for block and word counts plus a visible length guard that rejects messages beyond the fixed buffer capacity.
- **range**: Conversions from 32-bit modular values and Character positions into index subtypes are discharged by taking mod or masking before converting, so the provers see the bounded range.
- **overflow**: Additions and shifts occur on a 32-bit modular type where wraparound is defined, and only the 64-bit message bit-length multiplication needs a bound, which the capacity limit supplies.

## Language surface recorded by this assessment

Modular types, integer division, ranged subtypes, characters, arrays, for loops, string indexing, string building, procedures, functions, integers and Boolean objects.

## External effects

- **console output** (allowed): Print each embedded test string with its 32-hex-digit MD5 digest.

Assessed on 2026-10-15 against page revision 415178 of the [task](https://rosettacode.org/wiki/MD5) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
