# Solving coin problems

**Candidate: proofs plausibly discharge automatically.** The task is a text-pattern parser plus a small linear solver that bounded enumeration can handle, so every check follows from fixed buffers, ranged subtypes and for loops; the many loop-carried token indices need careful guards, hence plausible rather than likely.

Position 1203 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

The program embeds the example problems as constant strings, tokenizes each into a bounded array of words, recognizes the fixed sentence patterns (times as many, N more/less than, total coins, total value) and fills a small table of coefficients over at most three unknown coin kinds with values in cents. It then finds the counts by bounded for-loop enumeration against the equations, printing each solution, or a stated outcome when the text is not understood or no solution exists. About 450 lines.

## Proof obligations to watch

- **index**: Tokenizing English text into bounded word buffers and scanning for keywords computes positions in loops, so every access needs a guard against the buffer length just before use.
- **overflow**: Parsed dollar amounts and multipliers are held in ranged subtypes capped at the largest permitted figure, and over-large numbers reject the problem with a specified message.
- **termination**: All scanning and solving is done with for loops or while loops inside procedures, so no variant is needed.
- **length**: Word and sentence buffers have fixed capacity, and text that exceeds it yields a visible rejection outcome rather than truncation.
- **division**: The solver avoids division by a variable by enumerating each unknown's bounded count and testing the equations, so no divisor can be zero.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, records, string indexing, string building, 'Image of scalars, text parsing, case statements, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The solutions for each embedded problem are printed as text lines.

Assessed on 2026-10-15 against page revision 352152 of the [task](https://rosettacode.org/wiki/Solving_coin_problems) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
