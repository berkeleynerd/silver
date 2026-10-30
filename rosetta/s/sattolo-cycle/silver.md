# Sattolo cycle

**Candidate: proofs likely to discharge automatically.** Every check follows from array index subtypes, a reverse for loop with a nonzero modulus and a fixed-size output buffer, so no loop invariant is needed.

Position 1266 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Embed a constrained array of Integer (for example 11..22, plus a 52-element run), a modular-typed deterministic LCG with fixed seed, and a procedure Sattolo that loops i from Last down to 1 with reverse for, picks j = Natural(state mod i), and swaps items(i) and items(j) through a temporary. Main prints the array before and after via 'Image appended into a bounded line buffer and Put_Line, then checks in a for loop that no element remains in its original position and prints the result. About 55 lines.

## Proof obligations to watch

- **overflow**: The LCG state is a modular type so wraparound is defined, and the index j is computed as state mod i with i at least 1 inside a for loop that excludes zero, so division and range checks follow from types and loop bounds.
- **index**: Both swap indices lie in the declared index subtype because i comes from a reverse for loop over 1..Last and j is a mod result converted into a subtype whose range is guarded by j < i.
- **length**: The output line buffer is fixed-capacity sized for 12 or 52 elements of at most 3 digits plus separators, so appends never exceed capacity.

## Language surface recorded by this assessment

Integers, integer division, modular types, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the starting and shuffled arrays as text lines.

Assessed on 2026-10-15 against page revision 413408 of the [task](https://rosettacode.org/wiki/Sattolo_cycle) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
