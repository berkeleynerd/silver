# Chemical calculator

**Candidate: proofs plausibly discharge automatically.** Nested groups, symbol lookup and decimal masses can be handled with scaled integers, a bounded explicit stack and guards before each loop-carried addition, so no annotation is needed, but the guard placement needs care.

Position 860 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The element table is a constant array of records (three-character symbol, length, mass scaled by 10^9), and formulas are embedded in an array of fixed-length strings. An iterative procedure scans each formula with a cursor and a fixed-depth array stack of partial sums: an upper-case letter starts an atom whose lower-case letters are read (up to two) and looked up by a for loop, digits set a bounded multiplier, '(' pushes a new sum and ')' pops and scales it. Any unknown symbol, unbalanced parenthesis, stack overflow or cap overflow gives a printed rejection, and the scaled total is formatted to three decimals using integer division and 'Image. About 260 lines.

## Proof obligations to watch

- **overflow**: Masses are held as integers scaled by 10^9 in a 64-bit range type, and every multiply-and-add of a loop-carried total is preceded by a guard comparing against a documented cap, with over-cap formulas rejected visibly.
- **index**: The parser's group stack and the output buffer have fixed capacity, and every push, string index and lookup position is guarded by an explicit bound check that rejects too-deep or too-long formulas.
- **range**: Digit runs are accumulated into a count in a bounded subtype, so a guard rejects counts that would exceed the cap before each multiply-by-ten-and-add.
- **termination**: All loops are for loops or while loops inside procedures with a strictly advancing cursor, so no variant is needed as long as no function contains a while loop.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, case statements, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints each example formula with its computed molar mass, or a rejection message for malformed formulas.

Assessed on 2026-10-15 against page revision 415477 of the [task](https://rosettacode.org/wiki/Chemical_calculator) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
