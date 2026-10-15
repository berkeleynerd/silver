# Partial function application

**Candidate: proofs likely to discharge automatically.** Partial application maps directly onto Ada generic instantiation with a formal function, and every check follows from declared ranges, static array bounds and for loops over 'Range. No loop-carried value and no unbounded construct remains for the prover.

Position 1527 in the [progression](../../progression.md#stage-31), in stage 31.

## Approach

The program declares an unconstrained Sequence array of a ranged Value subtype and a generic function FS with a formal function F, whose body maps F over S'Range into a result array of the same bounds. F1 (2 * I) and F2 (I * I) are plain functions, and FSF1 and FSF2 are generic instances of FS, which is the partial application. A Print procedure uses Put with 'Image for each element and then ends the line, and Main applies both instances to the embedded aggregates (0,1,2,3) and (2,4,6,8). About 45 lines.

## Proof obligations to watch

- **overflow**: 2 * I and I * I are safe because the element subtype (for example -1000 .. 1000) bounds the operand so both results fit in Integer, with the results returned as Integer.
- **initialization**: The result array is initialized with an others => 0 aggregate, or filled by a for loop over its own 'Range, so flow analysis sees every element set.
- **index**: The result array is declared with S'First .. S'Last and the loop runs over S'Range, so indexing either array is safe from the declared bounds.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, unconstrained arrays, for loops, functions, procedures, generics, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The four result sequences are printed to standard output, one per line.

Assessed on 2026-10-15 against page revision 411873 of the [task](https://rosettacode.org/wiki/Partial_function_application) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
