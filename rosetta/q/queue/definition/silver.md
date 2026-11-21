# Queue/Definition

**Candidate: proofs likely to discharge automatically.** A bounded circular-buffer FIFO needs only ranged indexes, an array, a record and guarded procedures, so every check follows from types and guards placed just before use; the empty-pop error is handled by a returned flag rather than an exception, and the pointer, generic and tasking variants in the existing solution are avoided.

Position 1458 in the [progression](../../../progression.md#stage-27), in stage 27.

## Approach

The queue is a record holding a fixed-capacity circular array of Integer plus Head index and Count, with Push, Pop and Is_Empty as procedures and functions in a non-generic package. Push and Pop test full or empty just before touching the array, report failure through an out Boolean, and wrap the index explicitly instead of using mod. Main pushes ten values, pops them in a while loop until Is_Empty, then pops once more from the empty queue and prints a visible "queue empty" message. About 70 lines.

## Proof obligations to watch

- **index**: Head and Tail are ranged indexes advanced by explicit wraparound (if Idx = Capacity then Idx := 1 else Idx + 1), and Count is a range type guarded by Count < Capacity before Push and Count > 0 before Pop, so each check is local.
- **range**: Push on a full queue and Pop on an empty queue are guarded and return a Boolean Ok flag so the failure outcome is visible and nothing is silently dropped.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions, packages, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The demo prints each popped value and the outcome of popping from an empty queue.

Assessed on 2026-10-15 against page revision 412985 of the [task](https://rosettacode.org/wiki/Queue/Definition) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
