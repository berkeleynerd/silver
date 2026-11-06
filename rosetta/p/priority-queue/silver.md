# Priority queue

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged subtypes and index guards placed just before array accesses, and the loops live in procedures, so nothing needs an annotation, but the loop-carried heap indexes require careful guard placement.

Position 815 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

A fixed-capacity binary max-heap (capacity 16) stores records of a ranged priority and a task id in a constrained array plus a Count, with Insert and Remove_Top procedures using while-loop sift-up and sift-down guarded by index bounds, and a Boolean success flag for full or empty cases. Main inserts the five embedded items, then loops with a for loop over the item count removing the top and printing the priority image, " => " and the task name chosen by a case statement on the id. About 95 lines.

## Proof obligations to watch

- **index**: Heap indexes are loop-carried in sift-up and sift-down, so each loop uses a while condition that tests the parent or child index against the range 1..Capacity immediately before every array access, and the loop index type is a bounded subtype.
- **overflow**: Child index 2*I is computed only after a guard I <= Capacity/2, and the priorities are a small ranged subtype, so no arithmetic can overflow.
- **range**: Insert on a full queue and Remove on an empty queue are guarded by Count tests that return a Boolean success flag, and the main program prints a rejection message for the failure outcome, which cannot occur with the five embedded items.
- **termination**: The sift loops are while loops inside procedures, which get no termination check, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, case statements, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the five dequeued items in priority order with Put_Line.

Assessed on 2026-10-15 against page revision 413404 of the [task](https://rosettacode.org/wiki/Priority_queue) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
