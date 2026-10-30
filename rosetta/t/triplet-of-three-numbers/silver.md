# Triplet of three numbers

**Candidate: proofs likely to discharge automatically.** All indexes and arithmetic are bounded by static ranges and for loops over fixed limits, so no loop invariants or variants are needed and every check discharges from types and one guard. The only new work for Silver is integers, arrays, for loops and integer-to-text output.

Position 758 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed a Boolean array Prime (1 .. 6004) filled by a nested for-loop sieve (outer I over 2..77, inner K over 2..6004 with a guard on I*K) in a procedure, then loop N over 2..5999 testing Prime (N-1), Prime (N+3) and Prime (N+5) with and then. Each hit is printed with Put_Line from 'Image conversions of N and the three primes, padded to fixed width using small if comparisons. About 45 lines.

## Proof obligations to watch

- **index**: Prime table indexed by N-1, N+3, N+5 is safe because the table spans 1..6004 and the loop runs N over 2..5999, which follows from static bounds.
- **overflow**: Sieve products I*K stay below about 36 million when I and K are ranged subtypes up to 6004, and a guard I*K <= 6004 precedes the array index.
- **length**: Output lines are assembled from Integer'Image pieces whose maximum length is bounded by the ranged subtype, so concatenation lengths are statically bounded.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, functions, 'Image of scalars, string building, Put without a newline and case statements.

## External effects

- **console output** (allowed): Prints one line per qualifying n with Put_Line.

Assessed on 2026-10-15 against page revision 411162 of the [task](https://rosettacode.org/wiki/Triplet_of_three_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
