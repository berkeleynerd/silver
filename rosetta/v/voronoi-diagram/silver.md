# Voronoi diagram

**Candidate: proofs likely to discharge automatically.** The task is a nested for-loop nearest-site search over bounded integer coordinates with squared distances, so all checks follow from declared ranges and for-loop indexes and no loop invariant, floating point or recursion is needed. The only new needs are arrays, records, bounded text building and an admitted file-writing operation.

Position 1429 in the [progression](../../progression.md#stage-27), in stage 27.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

Use a fixed 64 by 64 pixel grid and a constant array of 12 site records (x, y, colour) embedded as literals. For each pixel a for loop over the sites computes the squared integer Euclidean distance and keeps the minimum and its site index, with no square root needed, then stores the site index in a two-dimensional cell array. A final procedure writes the grid to a PPM file using a site-to-colour table, with the file operation's failure outcome checked and rejected. About 90 lines.

## Proof obligations to watch

- **overflow**: Squared integer distances are computed on coordinates in a small declared range such as 0..63, so the sum of squares fits easily in Integer and discharges from types.
- **index**: Pixel and site loops run over the arrays' own index ranges and the nearest-site index is a subtype of the site array index initialized before the inner loop, so every index check follows from types.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, multidimensional arrays, records, for loops, procedures, string building, 'Image of scalars, file output and Put without a newline.

## External effects

- **files** (allowed): Writes the rendered diagram as a PPM image file, which meets the display requirement without a window.
- **console output** (allowed): Optionally prints a short status line when the image is written.

Assessed on 2026-10-15 against page revision 414992 of the [task](https://rosettacode.org/wiki/Voronoi_diagram) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
