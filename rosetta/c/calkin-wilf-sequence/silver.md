# Calkin-Wilf sequence

**Candidate: proofs plausibly discharge automatically.** Everything is small bounded integer arithmetic with iteration, so checks follow from ranged types and explicit guards with visible rejection, though several loop-carried values (denominator, term count, index accumulator) each need a guard placed just before use.

Position 267 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Rationals are held as numerator and denominator in ranged subtypes (small bound for part 1, up to 100000 for part 2), and part 1 loops for I in 1..20 applying next = b/((2*(a/b)+1)*b - a) with a guard that the new denominator is positive and bounded. Part 2 runs a while-loop Euclid in a procedure filling a 64-entry term array with a count guard, makes the count odd, then walks the terms in reverse with nested for loops doubling a capped accumulator and adding the parity bit. Lines are assembled with Integer'Image concatenation into bounded strings and printed with Put_Line. About 110 lines.

## Proof obligations to watch

- **overflow**: The next-term denominator (2*floor(a/b)+1)*b - a is loop-carried, so it is computed in a wider range and guarded to be within 1..limit with a visible rejection otherwise.
- **overflow**: The index accumulator Index*2+bit is loop-carried through nested loops over up to 83116 repetitions, so it needs a guard rejecting values above a fixed cap before each doubling, and the cap must still admit 123456789.
- **index**: The continued-fraction term array is capped at 64 entries and the Euclid while loop guards Count < 64 before each store, rejecting otherwise.
- **range**: The parity fix Terms(Count)-1 needs a guard that the last term exceeds 1 so the result stays positive, which Euclid guarantees but the prover must see from a visible test.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 20 terms and the position of 83116/51639.

Assessed on 2026-10-15 against page revision 415001 of the [task](https://rosettacode.org/wiki/Calkin-Wilf_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
