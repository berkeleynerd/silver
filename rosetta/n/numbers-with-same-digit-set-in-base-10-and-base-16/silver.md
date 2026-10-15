# Numbers with same digit set in base 10 and base 16

**Candidate: proofs likely to discharge automatically.** Every check follows from small constant bases, a 0 .. 15 array range, a for-loop bound and a guarded counter, and the while loop lives in a procedure so no variant is needed; the main work is just the new integer, array and string-building surface.

Position 343 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Two Boolean arrays indexed 0 .. 15 are filled by a procedure Fill_Digits (N, Base, Set) that uses a while loop with Nn mod Base and Nn / Base, and the main for loop over 0 .. 99_999 compares the two arrays element by element (or via array equality) and increments a bounded Count guarded by Count < 100_000. Output is each number via 'Image text built in a bounded String buffer with padding to fixed width, ten per line, followed by a total line, using Put_Line only if each row is assembled into a String first. About 55 lines.

## Proof obligations to watch

- **termination**: The digit-extraction while loop is placed in a procedure that fills a Boolean array so no termination check applies, and a for loop over 0 .. 99_999 always terminates.
- **index**: Set (Nn mod Base) is indexed by a value in 0 .. 15, which holds because Base is a constant 10 or 16 (or a subtype 10 .. 16) so the mod result is within the array range.
- **overflow**: The Count increment is bounded because Count is a subtype of 0 .. 100_000 and is only incremented once per iteration of a 100_000-iteration loop, so a guard before the increment (Count < 100_000) is needed since the loop-carried value is otherwise unbounded in the prover's view.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the matching numbers and the total count.

Assessed on 2026-10-15 against page revision 406168 of the [task](https://rosettacode.org/wiki/Numbers_with_same_digit_set_in_base_10_and_base_16) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
