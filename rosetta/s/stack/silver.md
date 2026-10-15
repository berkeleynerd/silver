# Stack

**Candidate: proofs likely to discharge automatically.** All checks are index and range checks on Top that guards placed right before each array access discharge, and the only while loop sits in the Main procedure, where no termination check applies, so no annotation is needed.

Position 600 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The stack is a record holding a fixed-capacity Integer array plus a Top count of subtype 0 .. Capacity, with Push and Pop as procedures that take a Success out flag. Push sets Success to False instead of writing when the stack is full, Pop returns False with a defined dummy value when it is empty, and Is_Empty is a Boolean function. Main pushes embedded values in a for loop, prints Is_Empty, then pops and prints values in a while loop until the stack is empty. About 60 lines.

## Proof obligations to watch

- **index**: Pop reads Items (Top) only after testing Top > 0 and Push writes Items (Top + 1) only after testing Top < Capacity, so both index checks follow from guards just before use.
- **initialization**: Pop assigns its out Item and Success parameters on both the empty and non-empty paths, and the stack record is initialized by an aggregate, so data-flow checks are routine.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, records, procedures, functions, 'Image of scalars, for loops and while loops.

## External effects

- **console output** (allowed): The demo prints pushed and popped values and the result of empty tests with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413053 of the [task](https://rosettacode.org/wiki/Stack) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
