# Sphenic numbers

**Candidate: proofs likely to discharge automatically.** All checks follow from declared ranges, for-loop indexes and a guard before each counter increment, and no while loop or recursion is needed, so proofs should discharge without annotations. The required output is small and the optional million-scale stretch parts are omitted.

Position 346 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

A function Is_Sphenic takes N in a ranged subtype (1 to 10_002). It loops P from 2 to N with a remainder and a factor count; a divisor increments the count and divides out P, and a count above 3 or a repeated factor returns False. A main procedure runs for loops over 1..999 and 1..9_999, printing each sphenic number and each triplet using Integer'Image concatenation, with the stretch counts (which would need million-scale trial division) left out as optional. About 55 lines.

## Proof obligations to watch

- **overflow**: The factor counter is guarded (return False once it reaches 3) before each increment, and the remainder is a ranged subtype that only shrinks by division, so no check depends on a loop invariant.
- **termination**: The function uses only for loops over static ranges, which terminate on their own, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, functions, for loops, 'Image of scalars and procedures.

## External effects

- **console output** (allowed): Prints the sphenic numbers below 1,000 and the sphenic triplets below 10,000 with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 414511 of the [task](https://rosettacode.org/wiki/Sphenic_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
