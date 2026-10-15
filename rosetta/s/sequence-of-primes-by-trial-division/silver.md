# Sequence of primes by trial division

**Candidate: proofs likely to discharge automatically.** Only for loops over statically bounded ranges are used, so termination needs no variant, the divisor D is at least 2 so the mod has no division-by-zero check to fail, and the loop-carried state is a Boolean.

Position 115 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

An embedded bounded range (for example 2 to 100, or 50 to 99 as in the sample) is walked by an outer for loop over a declared integer subtype, and an inner for loop tries every divisor D in 2 .. N-1, clearing a Boolean flag when N mod D = 0. Each prime is printed with Put_Line using Integer'Image, and no value is carried across iterations except the Boolean. About 22 lines.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each prime found in the embedded range to standard output.

Assessed on 2026-10-15 against page revision 413905 of the [task](https://rosettacode.org/wiki/Sequence_of_primes_by_trial_division) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
