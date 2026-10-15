# Pointers and references

**Candidate: proofs likely to discharge automatically.** The task only asks for common pointer and reference operations. SPARK's ownership-checked access types, allocators, deallocation and in out parameters can show these with literal values, so the null, overflow and leak checks all follow from straight-line control flow. The only open question is whether the Oracle's subtractive profile admits access types at all, and nothing here conflicts with a fixed rule.

Position 1573 in the [progression](../../progression.md#stage-38), in stage 38.

## Approach

Main declares a pool-specific access-to-Integer type, allocates an Integer with literal value 5, then reads, prints, assigns and prints it again through the pointer. It frees the object with an Ada.Unchecked_Deallocation instance. A procedure with an in out Integer parameter shows a reference, increments a small literal-initialized variable passed to it and prints the result. Ownership keeps exactly one access path to each object, so there is no aliasing. About 40 lines.

## Proof obligations to watch

- **heap**: A fixed, small number of allocations happens on a single path, so Storage_Error falls under Silver's fixed sufficient-memory premise and no allocation grows with input.
- **other**: Null dereference checks discharge because each pointer is initialized by an allocator immediately before use and is read only on that path.
- **other**: GNATprove's memory leak check discharges because each owning pointer is freed by an Unchecked_Deallocation instance before it goes out of scope, under SPARK ownership rules.

## Language surface beyond today's Silver

Integers, access types, generics, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the values read and written through the pointer and the reference parameter.

Assessed on 2026-10-15 against page revision 414405 of the [task](https://rosettacode.org/wiki/Pointers_and_references) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
