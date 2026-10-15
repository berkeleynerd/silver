# N'th

**Candidate: proofs likely to discharge automatically.** Every check follows from the declared subtype range (mod by non-zero literals, bounded image length, for-loop index), there are no loop-carried values, and the loops are plain for loops, so proofs should discharge without annotations.

Position 308 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

A ranged subtype (0..9999) is used for the values; a side-effect-free Suffix function uses if/elsif on N mod 10 and N mod 100 to return "st", "nd", "rd" or "th". A procedure Print_Range(From, To) loops with a for loop and calls Put_Line(Natural'Image(I) & Suffix(I)) (or the image without its leading space), and Main calls it for 0..25, 250..265 and 1000..1025. About 35 lines.

## Proof obligations to watch

- **length**: Concatenating the integer image with the suffix has a bounded length because the index subtype has a declared range, so the result fits String bounds and the check discharges from types alone.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, for loops, procedures, functions, 'Image of scalars and string building.

## External effects

- **console output** (allowed): The ordinals for the three required ranges are printed with Put_Line, one per line.

Assessed on 2026-10-15 against page revision 411625 of the [task](https://rosettacode.org/wiki/N'th) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
