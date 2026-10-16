# Raster bars

**Candidate: proofs likely to discharge automatically.** The task asks only to display moving gradient bars, which text-art frames on the console satisfy, and all indexing comes from constant tables, ranged subtypes and for-loop indexes with no loop-carried unbounded values. No floating point or recursion is needed.

Position 667 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

The program holds a constant integer sway table (precomputed sine values) and a gradient ramp string, and renders a fixed-size Character grid per frame with a for loop over a small number of frames. For each bar it computes the vertical offset from the table with a mod-bounded phase, fills ramp characters for the bar's rows (rising then falling for a metallic look), then prints each grid row via Put_Line, optionally with a vertical bar column set the same way. All indexes are bounded by subtypes and the grid leaves margin for the maximum sway, so no runtime guards are needed. About 70 lines.

## Proof obligations to watch

- **index**: Row index is Center + Sway(Frame + Phase) + Step, which discharges because Sway is a constant table of a bounded subtype, Center leaves margin for that range, and frame phase indexes use mod into the table's range.
- **range**: Gradient character selection indexes a constant ramp string by the bar step, a for-loop index whose range equals the ramp bounds.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, multidimensional arrays, for loops, procedures, string indexing, string building and Put without a newline.

## External effects

- **console output** (allowed): Each animation frame is written as lines of text art with Put_Line, so no window or delay is needed.

Assessed on 2026-10-15 against page revision 414432 of the [task](https://rosettacode.org/wiki/Raster_bars) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
