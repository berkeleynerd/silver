# Square but not cube

**Candidate: proofs likely to discharge automatically.** All products fit the declared small Integer ranges, and the direct Count<30 guard justifies the increment. Cubes include every candidate cube up to 1600; scanning increasing square roots and stopping output after 30 qualifying values gives the required prefix through 1089. Independent expected output uses square/cube set difference. Scope and validation status are recorded in docs/boolean-objects.md and the linked assessment record.

Position 48 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The driver samples/rosetta_square_but_not_cube.adb computes Root*Root for Root in 1..40. It scans Trial in 1..13 and sets a Boolean Cube flag if Trial*Trial*Trial equals the square. When not Cube and then Count<30 it increments the bounded counter and streams the square with Put and Integer Image. A final empty Put_Line ends the line. It prints exactly the required first 30 values; the optional common squares and cubes are omitted. About 22 lines.

## Proof obligations to watch

- **range**: Square fits 1..1600 from Root in 1..40; each cube product fits Integer from Trial in 1..13; the direct Count<30 guard makes the increment fit 0..30.

## Language surface recorded by this assessment

Scalar Boolean objects and expressions, bounded mutable Integer objects, scalar guard refinement, Integer range for loops, Integer image and Put without a newline.

## External effects

- **console output** (allowed): Prints the 30 qualifying squares on one line.

Initially assessed on 2026-10-15 against page revision 415318 of the [task](https://rosettacode.org/wiki/Square_but_not_cube) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-30 by Codex through targeted source review; see the [review record](../../../rosetta/assessment-boolean-objects-20261030.md).
