# Safe primes and unsafe primes

**Candidate: proofs likely to discharge automatically.** Every check follows from the static range of a for-loop index or the declared range of a counter, plus one guard before each increment that can never be false. No loop or call needs a variant, and no memory use grows with input, so the proof should discharge without annotations.

Position 357 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

A side-effect-free Is_Prime function does trial division with a for loop over D in 2 .. 3163. It returns True as soon as D * D > N and False on the first divisor, so it needs no variant and no large sieve array on the stack. Main makes one for-loop pass over 2 .. 9_999_999 for safe primes and one for unsafe primes. Each pass uses Put and 'Image to print a candidate while its counter is still below 35 (or 40), saves the count when the candidate reaches 1_000_000, and prints both counts after the loop. Each counter increment is guarded against the counter type's bound. About 70 lines.

## Proof obligations to watch

- **overflow**: The safe and unsafe counters are carried through a 10-million-iteration for loop with no invariant, so each increment sits behind a guard against the counter type's upper bound; the guard can never fail because the count cannot exceed the number of candidates.
- **overflow**: In Is_Prime the trial divisor D runs over the static range 2 .. 3163, so D * D is at most about 10 million and the provers bound it easily from the loop index's range.
- **termination**: Is_Prime is a function, so it uses a for loop over a static divisor range that returns early, which is the shape that needs no variant.

## Language surface beyond today's Silver

Integers, integer division, Boolean objects, functions, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The two prime lists and the four counts are written to standard output.

Assessed on 2026-10-15 against page revision 413008 of the [task](https://rosettacode.org/wiki/Safe_primes_and_unsafe_primes) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
