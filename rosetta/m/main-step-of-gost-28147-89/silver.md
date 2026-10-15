# Main step of GOST 28147-89

**Candidate: proofs likely to discharge automatically.** All arithmetic is on a wraparound modular type with for loops over fixed nibble indexes, so no overflow, range or index check depends on a loop-carried value and nothing needs an annotation.

Position 1279 in the [progression](../../progression.md#stage-23), in stage 23.

## Approach

Represent the two 32-bit halves and the key element as a 32-bit modular type, the substitution table as a constant 8x16 array of 4-bit-ranged values, and apply the main step as a function: add the key modulo 2^32, loop over the eight nibbles with a for loop replacing each via the table, rotate left 11 using modular multiply and divide by powers of two, xor with the other half, and swap. A Main procedure runs the step on embedded example data and prints the two halves as hex digits using a constant digit string indexed by a value reduced mod 16. About 60 lines.

## Proof obligations to watch

- **range**: Each nibble extracted from the 32-bit sum by division and mod 16 is converted to a 0..15 table index, which follows from the mod bound and discharges without loop-carried facts.
- **index**: The hexadecimal output digit lookup uses a value reduced mod 16 into a 16-character constant, so the index bound is statically evident.

## Language surface beyond today's Silver

Modular types, ranged subtypes, arrays, multidimensional arrays, integer division, for loops, functions, procedures, characters, string indexing and string building.

## External effects

- **console output** (allowed): The program prints the resulting 64-bit block as hexadecimal text for the embedded example data.

Assessed on 2026-10-15 against page revision 414326 of the [task](https://rosettacode.org/wiki/Main_step_of_GOST_28147-89) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
