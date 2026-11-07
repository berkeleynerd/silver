# Magic numbers

**Candidate: proofs plausibly discharge automatically.** No big numbers are needed because only prefix remainders modulo at most 25 are tracked, and every loop is a procedure while loop over bounded subtypes, so checks follow from types and depth guards. The nonroutine part is the loop-carried depth cursor and counters, which need careful typing.

Position 470 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Digits of the current prefix are held in a fixed array of 25 digit values with a depth cursor, and an iterative depth-first search in a procedure tries digits 0..9 at each depth, keeping a prefix only when its remainder modulo its length is zero (recomputed from the digits with small remainders). Each accepted prefix increments a total and a per-length count array, the deepest one is copied into a 25-character buffer for the largest, and length 9 or 10 prefixes are checked for pandigitality with a seen-digit Boolean array and printed through a bounded text buffer. Integers are converted to text by 'Image-style digit conversion and all depth and digit indexes are range subtypes guarded before use. About 130 lines.

## Proof obligations to watch

- **index**: The depth cursor of the iterative search is loop-carried, so it is typed as a subtype 1..25 and every increment is guarded by a depth check just before use, with the 26th digit rejected explicitly since none exists.
- **overflow**: Prefix values exceed 64 bits, so the program never forms them and instead recomputes the prefix remainder digit by digit as (r*10+d) mod n with r below n at most 25, which a subtype range keeps within bounds.
- **range**: Counters (total at most 20457, per-length counts) are loop-carried and typed with a generous range subtype so increments cannot overflow.
- **termination**: The depth-first search is a while loop inside a procedure, which gets no termination check, and the real bound is the 25-digit depth limit.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, procedures, functions, for loops, while loops, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the total count, the largest magic number, per-length counts and the pandigital numbers.

Assessed on 2026-10-15 against page revision 414321 of the [task](https://rosettacode.org/wiki/Magic_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
