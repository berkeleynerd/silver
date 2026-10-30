# NYSIIS

**Candidate: proofs plausibly discharge automatically.** The task is pure text processing over bounded character buffers, so every check follows from the buffer's declared capacity, for-loop ranges and guards before each look-behind or look-ahead. It is plausible rather than likely only because many loop-carried lengths need guards and many rewrite passes must be written carefully.

Position 946 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Embed the sample names as String constants in an array, and for each one copy its uppercased letters into a fixed 64-character buffer with a length counter, rejecting names longer than the capacity with a visible message. Apply the original NYSIIS rules as a series of procedures, each a for loop copying from one buffer to another with explicit length guards: prefix rules, suffix rules, vowel mapping, H and W handling, trailing S and A removal, and duplicate collapse. Print the name and the code with Put_Line; the optional suffix and multi-name handling is a small table of suffixes tested by length-guarded comparison. About 230 lines.

## Proof obligations to watch

- **index**: Every look-behind, look-ahead and prefix or suffix test (MAC, SCH, DT, EV, the previous character) must be guarded by a length comparison just before the access, which is routine but needs care throughout.
- **length**: The buffer holds 64 characters and each rewrite step (such as MAC to MCC, SCH to SSS, EV to AF) never lengthens the text beyond the bound, with an explicit guard before every append so the buffer cannot overflow.
- **range**: The loop-carried logical length is a subtype bounded by the buffer capacity, so index arithmetic on it discharges from its type, but each increment needs a guard against the capacity.
- **termination**: The in-place rewrite passes use for loops, or while loops inside procedures, so no function needs a variant.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, for loops, while loops, procedures, functions and conditional expressions.

## External effects

- **console output** (allowed): Prints each embedded sample name with its NYSIIS code via Put_Line.

Assessed on 2026-10-15 against page revision 402083 of the [task](https://rosettacode.org/wiki/NYSIIS) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
