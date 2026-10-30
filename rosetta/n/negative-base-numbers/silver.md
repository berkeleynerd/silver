# Negative base numbers

**Candidate: proofs plausibly discharge automatically.** All checks come from declared ranges, a bounded buffer and explicit guards, but the loop-carried accumulators and the remainder correction need carefully shaped guards for the provers to discharge automatically.

Position 557 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

A procedure encodes an Integer in the range -10**9..10**9 into a fixed 64-character buffer, using rem and / with the negative-base remainder correction and a 62-character digit table, and then reverses the digits. A second procedure decodes by Horner's rule over the string, guarding each character against the table and the accumulator against a safe bound before multiplying. Main runs the embedded cases (10 in base -2, 146 in base -3, 15 in base -10, and 36058 in base -62 giving Ada) and prints each result and round trip with Put_Line and Image. About 110 lines.

## Proof obligations to watch

- **overflow**: The decoded accumulator is loop-carried with no invariant, so a guard before each Total*Base+digit step rejects values beyond a safe bound such as 10**15 with a visible failure message.
- **index**: The encode remainder after the negative-base correction is derived from rem against a Base subtype of -62..-2, and the digit table lookup needs a guard or subtype range so it provably lies in 0..61.
- **length**: The digit buffer is a fixed 64-character array and a guard rejects any encoding that would exceed it, then the digits are reversed or copied into a fixed-size output string.
- **termination**: The encode and decode while loops live in procedures, which get no termination check, though a bounded for loop with an early exit is a safer alternative.
- **range**: Mapping characters back to digit values requires a validated character lookup that rejects any character not in the digit table.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, 'Image of scalars, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints each number, its negative-base encoding and the decoded value.

Assessed on 2026-10-15 against page revision 412023 of the [task](https://rosettacode.org/wiki/Negative_base_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
