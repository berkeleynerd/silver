# Memory allocation

**Candidate: proofs likely to discharge automatically.** SPARK's ownership model already admits a fixed-size allocation followed by an explicit Unchecked_Deallocation, and its null-dereference and leak checks follow from straight-line code, so the program should prove without annotations; Storage_Error stays under the Oracle's fixed-memory premise because the allocation does not grow with input.

Position 1572 in the [progression](../../progression.md#stage-38), in stage 38.

## Approach

Main shows stack allocation with a declare block that holds a small fixed-size Integer array, which is reclaimed when the block ends. It shows heap allocation with an access type, an initialized allocator (new Block'(...)) and an instance of Ada.Unchecked_Deallocation called explicitly as Free, printing the values with 'Image along the way. The parts about shared and foreign memory are marked "if applicable" and are left out. About 30 lines.

## Proof obligations to watch

- **heap**: The program makes one heap allocation of fixed size that does not depend on input, so the Oracle's premise of sufficient memory covers it, and SPARK's leak check passes because the program calls Free explicitly before the pointer goes out of scope.
- **other**: Dereferencing the pointer discharges its null check because the dereference comes straight after an initialized allocator (new T'(...)), and after Free the pointer is not used again.

## Language surface beyond today's Silver

Integers, arrays, block statements, access types, generics and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the values held in the stack-allocated and heap-allocated blocks to show that each allocation worked.

Assessed on 2026-10-15 against page revision 413783 of the [task](https://rosettacode.org/wiki/Memory_allocation) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
