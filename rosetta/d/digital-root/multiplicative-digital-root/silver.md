# Digital root/Multiplicative digital root

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded by declared subtypes and explicit guards placed before each multiplication, and the loops sit in procedures, so no annotations are needed, but the loop-carried product and the formatting arithmetic need careful program shape.

Position 256 in the [progression](../../../progression.md#stage-9), in stage 9.

## Approach

Embed the four inputs in a constant array; a procedure computes MDR and MP using a while loop that extracts digits with mod/div and multiplies them into a range-typed, guarded accumulator, repeating until the value has one digit. A for loop scans candidates 0..11111 (the largest needed value), and each candidate whose MDR has fewer than five stored entries is stored in a 10x5 array, after which the tables are formatted into bounded buffers and printed with Put and Put_Line. About 90 lines.

## Proof obligations to watch

- **overflow**: The digit-product accumulator is loop-carried without an invariant, so each multiplication is guarded (multiply only when the product is at most 59049 inside a 0..531441 subtype) with a visible rejection otherwise, which the task's inputs never trigger.
- **range**: Inputs and scanned candidates are held in a bounded subtype (0..999999) and the MDR/MP values are assigned from guarded results, so subtype checks follow from the declared ranges and guards.
- **index**: The results table is indexed by MDR 0..9 and count 1..5, with a guard that the count is below 5 before storing, so indexes follow from the types and the guard.
- **length**: Output lines are built in fixed-size buffers with padding computed from bounded digit counts, so a guard on the position keeps every slice within the buffer.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the MP/MDR table for four numbers and the table of the first five numbers per MDR.

Assessed on 2026-10-15 against page revision 413690 of the [task](https://rosettacode.org/wiki/Digital_root/Multiplicative_digital_root) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
