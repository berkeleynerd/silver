# Fibonacci word

**Candidate: proofs plausibly discharge automatically.** All checks follow from array bounds and a few explicit overflow and positivity guards, but the carried sums and the floating-point entropy need careful guard placement, and the full 24-million-character words are not materialized.

Position 1080 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Store only per-word length and counts of 0 and 1 in arrays indexed 1..37 (the entropy depends only on these, avoiding 24-million-character buffers), computing each entry as the sum of the previous two, and build explicit short words in a small bounded buffer for the first nine words to display them. A for loop fills the arrays with guarded additions, then a second for loop computes entropy per word with guards on the length and ratios and prints each table row. About 90 lines.

## Proof obligations to watch

- **overflow**: The length and symbol-count recurrences are loop-carried sums with no invariant, so each addition is guarded against a documented limit (above the 24157817 needed) with a visible Reject outcome.
- **floating point**: The entropy is -p*log2(p) per symbol with p = count/length, so p must be guarded to lie in (0,1] before Log, relying on range guards and the library Log contract.
- **division**: The length divisor is a loop-carried array element, so a guard that it is positive is placed directly before each division.
- **index**: Short words are built in a bounded 34-character buffer only for words of length at most 34, with the length guarded before each copy.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops, floating point, floating-point images, 'Image of scalars, string building, string indexing, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The table of word number, length and entropy, plus the first few words, is written to standard output.

Assessed on 2026-10-15 against page revision 415021 of the [task](https://rosettacode.org/wiki/Fibonacci_word) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
