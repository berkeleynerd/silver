# Bitmap

**Candidate: proofs likely to discharge automatically.** Every check is an array index or a subtype range, discharged by for-loop bounds over the array's own ranges or by a guard just before the access, and nothing needs a loop invariant, recursion or heap, so the proofs should discharge routinely.

Position 886 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

The image is a fixed-capacity two-dimensional array (for example 16 by 8) of Pixel records whose R, G and B components are an integer subtype 0..255, with an Allocate function returning an all-black aggregate and a Fill procedure using nested for loops over the array's own ranges. Set_Pixel and Get_Pixel guard Positive coordinates against the fixed bounds (Set_Pixel returns a Boolean success flag; Get_Pixel returns black when out of range and the caller checks first), and Main fills white, sets and copies a few pixels, then prints a text-art rendering with Put and Put_Line. All control flow is straight-line code plus for loops, so there are no loop-carried values. About 60 lines.

## Proof obligations to watch

- **index**: Set_Pixel and Get_Pixel take X and Y as Positive and test them against the fixed Width and Height with an explicit guard that reports out-of-range coordinates, so every array access is provably in bounds.
- **initialization**: The Image array is fully assigned by Fill (or an aggregate) before any read, which is easy for flow analysis on a whole-array aggregate but would be less routine if left uninitialised, so Allocate returns an all-black aggregate.

## Language surface recorded by this assessment

Ranged subtypes, records, arrays, multidimensional arrays, characters, for loops, procedures, functions, Boolean objects, integers, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): A text-art dump of the image is printed to check the fill, set and get results.

Assessed on 2026-10-15 against page revision 414081 of the [task](https://rosettacode.org/wiki/Bitmap) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
