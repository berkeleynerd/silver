# Consistent overhead byte stuffing

**Candidate: proofs plausibly discharge automatically.** Everything is bounded array and counter logic that types and just-before guards can discharge, but several loop-carried indexes and the hex formatting need careful guard placement, so it is plausible rather than likely.

Position 1307 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Bytes are a modular 8-bit type stored in fixed-capacity arrays (about 600 bytes) with a length record, and the eleven example packets are built by for loops into embedded arrays. Encode and decode are procedures that walk the input with a running code counter and a code-byte position, flush at zero bytes or at 255, apply Xor with the marker, and the decoder rejects a milestone pointing past the packet end or a missing trailing marker with a printed error and an empty result. A hex-printing procedure writes the first and last five bytes of each array. About 170 lines.

## Proof obligations to watch

- **index**: Output buffer indexes (encoder write position, code-byte position) are loop-carried, so each write is guarded by an explicit capacity check that rejects over-long input with a visible outcome.
- **range**: The run-length code counter is a subtype 1..255 and is reset or flushed by a guard when it reaches 255, so increments never leave the range.
- **overflow**: Length arithmetic (position plus code byte versus packet length) uses Natural-bounded types small enough that sums cannot overflow, and the decoder checks the milestone against the remaining length before copying.
- **termination**: All loops are for loops or while loops inside procedures, so no termination check is generated.
- **other**: Xor with a non-zero marker needs a modular Byte type with conversions, which is routine once the byte type is a modular 8-bit type.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, modular types, Boolean objects, characters, arrays, records, string building, for loops, while loops, procedures, functions, Put without a newline, 'Image of scalars and case statements.

## External effects

- **console output** (allowed): Prints each example's hex input, encoded and decoded forms, and any decode error message.

Assessed on 2026-10-15 against page revision 414127 of the [task](https://rosettacode.org/wiki/Consistent_overhead_byte_stuffing) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
