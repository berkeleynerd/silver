# Special pythagorean triplet

**Candidate: proofs likely to discharge automatically.** The retained prototype passed admission only under today's compiler. Loop-index intervals bound every intermediate arithmetic result, Found assignments stay in 0 .. 1 and Product accepts the bounded product. No Boolean object, declared subtype, guard refinement, new division operator, proof or execution result is claimed.

Position 65 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main initializes Found : Integer range 0 .. 1 := 0 and Product : Integer := 0. Nested Integer range loops run A over 1 .. 333 and B over (A + 1) .. 500. An if with Found = 0 and then the grouped equality ((A * A) + (B * B)) = (((1000 - A) - B) * ((1000 - A) - B)) selects the first match, sets Found := 1 and assigns Product := ((A * B) * ((1000 - A) - B)). After the loops Put_Line prints Integer'Image (Product), which is 31875000 for the task's fixed sum. If the search found no match, its initialized product would visibly be zero. A bounded Integer flag replaces a Boolean object, and grouped expressions avoid a local C declaration. About 30 lines.

## Proof obligations to watch

- **overflow**: A lies in 1..333 and B in 2..500; C = 1000-A-B lies in 167..997. Squares, their sum and the conservatively bounded product at most 333*500*997 = 166000500 fit signed 32-bit Integer.
- **range**: Found starts at 0 and is only assigned 1, both inside its declared 0..1 range. Product is initialized and unconstrained Integer; there is no C object assignment or Boolean state.

## Language surface recorded by this assessment

Integer range for loops, immutable Integer arithmetic, Integer image and bounded mutable Integer objects.

## External effects

- **console output** (allowed): Prints the product of the triplet (and optionally the triplet) with Put_Line.

Initially assessed on 2026-10-15 against page revision 403490 of the [task](https://rosettacode.org/wiki/Special_pythagorean_triplet) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-division-20261025.md).
