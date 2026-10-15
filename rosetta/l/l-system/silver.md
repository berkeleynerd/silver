# L-system

**Candidate: proofs likely to discharge automatically.** All loops are for loops over static or bounded ranges inside procedures, and every array write is guarded by a capacity check, so the checks follow from types and guards without any invariant. The task's callback/closure-based generality is met with a case-statement interpreter over the embedded rabbit example, which needs no unsupported language feature.

Position 781 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

The current string is a fixed-capacity Character array with a length of a ranged subtype, starting from the embedded axiom "I", and a procedure applies the rules (I to M, M to MI, others unchanged) through a case statement on each character, writing into a second buffer. A for loop over a fixed step count of 5 prints each generation and rewrites it, with a capacity guard before every append that rejects on overflow; the interpretation then walks the final string with a case statement that counts mature and immature rabbits and prints the totals. About 70 lines.

## Proof obligations to watch

- **index**: Appending a rewrite to the bounded buffer is guarded by an explicit capacity test just before each write, with overflow leading to a visible rejection.
- **range**: The buffer length is a loop-carried value whose subtype range (0..Capacity) plus the pre-append guard keeps every index and increment in range.

## Language surface beyond today's Silver

Characters, ranged subtypes, integers, arrays, string building, for loops, case statements and procedures.

## External effects

- **console output** (allowed): Each computed generation and the interpretation result are printed as lines.

Assessed on 2026-10-15 against page revision 415424 of the [task](https://rosettacode.org/wiki/L-system) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
