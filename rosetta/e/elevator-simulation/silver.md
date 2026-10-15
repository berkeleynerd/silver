# Elevator simulation

**Candidate: proofs likely to discharge automatically.** The task is only a video-described elevator GUI, so a faithful text simulation with a bounded queue and 0..6 floor range needs just ranged types, small arrays and guarded updates, all of which GNATprove discharges from types and guards. No annotation, recursion or heap is needed, and the graphical display is replaced by text output.

Position 1176 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

A text simulation keeps the car floor (subtype 0..6), a door Boolean, a WAIT-sign floor and a fixed-capacity queue array of an Action enumeration (floor buttons, up, down, door toggle), seeded with a scripted list of button presses and fixed starting state instead of random state and mouse clicks. A procedure pops the head of the queue, applies it with a case statement (moving one floor per step in a while loop, guarded at the ends), re-queues a door toggle when the WAIT floor is reached (printing a visible 'queue full' line if capacity is exhausted), and prints the state line using 'Image text for each step. Output goes through Put and Put_Line, with the script bounded so the queue never exceeds its declared capacity. About 110 lines.

## Proof obligations to watch

- **range**: The queue count and floor are subtypes (0..Capacity, 0..6) updated in loop-carried fashion, and each increment or decrement sits directly behind a guard (Count < Capacity, Floor < 6, Count > 0) so no invariant is needed.
- **index**: The queue shift loop runs over a for range derived from the count subtype, so indexes stay within the array's own bounds.
- **termination**: All loops live in procedures (which get no termination check), and the move loop steps the floor one at a time toward the target within a 0..6 range.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, enumerations, arrays, case statements, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The simulation prints the elevator state (floor, door, WAIT sign) as text lines after each step.

Assessed on 2026-10-15 against page revision 384637 of the [task](https://rosettacode.org/wiki/Elevator_simulation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
