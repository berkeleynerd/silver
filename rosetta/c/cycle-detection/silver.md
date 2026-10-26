# Cycle detection

**Candidate: proofs plausibly discharge automatically.** All checks follow from the 0..254 value range and capped counters with guards, and the unbounded-looking while loops sit in a procedure so no termination annotation is needed; the plausible rating reflects the loop-carried counters needing careful cap guards and the new integer, array-free string-building and 'Image surface.

Position 374 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Define a Value subtype 0..254 and a function F returning (X*X+1) mod 255, then a procedure Brent with a power-of-two phase loop and a Mu-finding loop using bounded Count subtypes (say 0..1_000_000) for Power, Lambda and Mu. Main prints the first 41 terms with a for loop into a bounded string buffer via 'Image, then the cycle length and start index, using a guard that reports a specified failure if a counter would reach its cap. About 70 lines.

## Proof obligations to watch

- **termination**: Brent's while loops live in a procedure so no termination check applies, and the function F itself has no loops.
- **overflow**: Using subtype Value is Integer range 0..254 makes X*X+1 at most 64517, and Power and Lambda are bounded by a declared Count subtype with a guard that stops (with a visible failure outcome) before they exceed it.
- **range**: Loop-carried Power, Lambda and Mu are only bounded by their type ranges, so doubling Power and incrementing Lambda and Mu need guards against the declared cap just before each update.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 41 sequence terms, the cycle length and the start index.

Assessed on 2026-10-15 against page revision 413569 of the [task](https://rosettacode.org/wiki/Cycle_detection) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
