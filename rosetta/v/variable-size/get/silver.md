# Variable size/Get

**Candidate: proofs likely to discharge automatically.** The straight-line plan needs an Integer object Size-attribute read, integer division by a literal and Image output. Its attribute value, Integer range and target interpretation still need an admission rule; Size-clause support would not by itself admit this read.

Position 1572 in the [progression](../../../progression.md#stage-41), in stage 41, which adds Integer object Size attribute reads.

## Approach

Declare an initialized Integer variable X and Integer constants holding X'Size in bits and that value divided by 8 in bytes on the pinned eight-bit-storage-unit targets. Print both through Integer'Image with Put_Line. X'Size reads the representation attribute of an object; it is a different construct from a Size representation clause that requests a representation. There are no loops, and division uses a static nonzero literal. About 10 lines.

## Language surface recorded by this assessment

Integers, integer division, 'Image of scalars and Integer object Size attribute reads.

## External effects

- **console output** (allowed): Prints the variable's size in bits and bytes with Silver_IO.Put_Line.

Initially assessed on 2026-10-15 against page revision 414570 of the [task](https://rosettacode.org/wiki/Variable_size/Get) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../../assessment-division-20261025.md).
