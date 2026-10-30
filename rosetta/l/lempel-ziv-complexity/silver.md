# Lempel–Ziv complexity

**Candidate: proofs plausibly discharge automatically.** The algorithm only needs bounded integer counters, character comparisons and a while loop inside a procedure, so no termination proof is needed. Several loop-carried relations (I < U, U+Vmax <= N+1) would normally need an invariant, so each must be replaced by an explicit guard just before its use. That makes discharge depend on careful program shape rather than being routine.

Position 995 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Main calls a procedure Report(S : String) once for each of the 18 embedded test strings, including the empty one. Report rejects strings longer than 64 characters. It then runs the classic LZ76 scan in a while loop over the integer counters I, U, V and Vmax (subtype 0..64), comparing S(S'First+I+V-1) with S(S'First+U+V-1) and putting a guard before each index and counter update. It prints the string followed by Integer'Image of the complexity, and leaves out the optional phrase listing. About 70 lines.

## Proof obligations to watch

- **index**: Reads at offsets I+V and U+V are safe from the loop condition U+V <= N for the second, but I < U is a loop-carried fact, so the first needs an explicit guard I+V <= N (unreachable in practice) that reports an internal error rather than an invariant.
- **range**: Updates V := V+1, U := U+Vmax and Vmax := V on counters typed 0..64 need guards just before each assignment (V+1 follows from U >= 1 and U+V <= N, but U+Vmax <= N+1 needs an explicit check with a visible rejection branch).
- **length**: The result line concatenates the test string with an image, so the procedure first rejects strings longer than the documented 64-character limit, which bounds the concatenation and keeps every offset computation from overflowing.
- **termination**: The while loop sits in a procedure, so no termination check arises, and every iteration either advances V or I toward a bound fixed by N.

## Language surface recorded by this assessment

Integers, ranged subtypes, procedures, unconstrained arrays, string indexing, while loops and 'Image of scalars.

## External effects

- **console output** (allowed): Each test string is printed with its computed LZ76 complexity through Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 408001 of the [task](https://rosettacode.org/wiki/Lempel%E2%80%93Ziv_complexity) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
