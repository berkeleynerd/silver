# Subtractive generator

**Candidate: proofs likely to discharge automatically.** Every value is bounded by its element subtype, the only arithmetic is a linear subtraction followed by an add-m guard, and every index is a fresh mod 55 of a for-loop index, so all checks follow from types and local guards.

Position 132 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Main stores the 55 seed values S and the ring buffer R in arrays indexed 0 .. 54 whose elements have the subtype 0 .. 10**9 - 1, with seed 292929 embedded. One for loop fills S(2 .. 54) with the subtractive formula and a second sets R(I) := S((34 * (I + 1)) mod 55). A third loop over N in 55 .. 222 updates R(N mod 55) from R(N mod 55) - R((N + 31) mod 55), adding 10**9 when the difference is negative, and prints the value with 'Image whenever N >= 220. About 35 lines.

## Proof obligations to watch

- **range**: Each difference of two elements typed 0 .. 10**9 - 1 lies in -(10**9 - 1) .. 10**9 - 1, and the guard "if D < 0 then D := D + M" just before storing brings it back into the element subtype by linear reasoning.
- **index**: Ring-buffer and reorder indexes are computed fresh from the for-loop index as N mod 55, (N + 31) mod 55 and (34 * (N + 1)) mod 55, so each lies in 0 .. 54 from the mod alone with no loop-carried index.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints r220, r221 and r222 for the embedded seed 292929 with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413933 of the [task](https://rosettacode.org/wiki/Subtractive_generator) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
