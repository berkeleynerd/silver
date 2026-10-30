# Dragon curve

**Candidate: proofs plausibly discharge automatically.** The task is a pure integer walk over a bounded grid whose checks follow from ranged subtypes and explicit pre-store guards, so it needs no annotations and only mild guard shaping for the loop-carried coordinates.

Position 802 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The program uses the iterative turtle method: for each segment n from 1 to a fixed 1023, a while loop in a procedure halves n until it is odd to find the bit above the lowest 1-bit and so turn left or right, and the direction (0..3) is held as a ranged integer updated with mod 4. The position is advanced with a case statement on direction, guarded against leaving a fixed 2D Character grid, marking each visited point; afterwards for loops copy each grid row into a String and print it with Put_Line. All output is console text art with no recursion or floating point. About 70 lines.

## Proof obligations to watch

- **range**: The x and y coordinates are loop-carried, so each step is guarded with an explicit check that the next point lies inside the fixed grid, and the program prints a visible 'curve exceeds grid' message and stops otherwise.
- **overflow**: The segment index and the halving loop that finds the bit above the lowest 1-bit use a small declared integer range with n/2 shrinking each pass, so no overflow is possible.
- **index**: Grid writes and row-string indexing use coordinates held in the grid's index subtype, which is established by the guard just before each store, plus for loops over the array's own range for printing.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, for loops, while loops, case statements and procedures.

## External effects

- **console output** (allowed): The curve is printed as rows of text art with Silver_IO.Put_Line, which meets the display-or-image-file requirement.

Assessed on 2026-10-15 against page revision 415437 of the [task](https://rosettacode.org/wiki/Dragon_curve) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
