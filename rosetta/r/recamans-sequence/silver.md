# Recaman's sequence

**Candidate: proofs plausibly discharge automatically.** The task needs only integer arithmetic, a fixed-size Boolean array and for loops, and every loop-carried check is closed by subtype ranges and guards placed just before the use. The 328002-term optional part is a bounded loop, so no annotation is needed.

Position 238 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

One main procedure keeps the current term in a bounded integer subtype and a Boolean 'used' array indexed 0..1000. Three passes in for loops compute a(n) by testing a-n positive and unused, otherwise a+n behind a cap guard, then print the first 15 terms, report the first repeated term index, and count terms until all of 0..1000 are seen using a covered-count counter. Output is built from 'Image text via Put_Line and Put. About 70 lines.

## Proof obligations to watch

- **overflow**: The current term and the sum a+n are loop-carried, so the term is a bounded subtype (0 .. 10**12) and an explicit guard before the addition rejects with a visible outcome if the cap were exceeded, instead of relying on an invariant.
- **index**: The Boolean 'used' array covers 0..1000 and every read or write is preceded by a guard that the term lies in 0..1000, since terms can exceed 1000.
- **range**: The subtraction a(n)-n is checked for positivity before being assigned to the non-negative subtype, and the mapping of Natural-valued terms into the array index is guarded.
- **termination**: All loops live in the main procedure, which gets no termination check, and the 328002-term search uses a for loop over a fixed 2_000_000 range with exit when.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, 'Image of scalars, string building, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 15 terms, the first duplicated term index and the term count for covering 0..1000.

Assessed on 2026-10-15 against page revision 414981 of the [task](https://rosettacode.org/wiki/Recaman's_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
