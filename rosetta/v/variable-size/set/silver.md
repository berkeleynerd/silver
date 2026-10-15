# Variable size/Set

**Candidate: proofs likely to discharge automatically.** The only run-time checks are static initializations within declared ranges and images of static attribute values, so every proof obligation is trivial. The one open question is a language-policy one, not a proof one: whether Silver will also admit an explicit Size aspect, which is neither a pragma nor a contract, so no Oracle rule forbids it.

Position 39 in the [progression](../../../progression.md#stage-3), in stage 3.

## Approach

The program declares a few integer types whose ranges (for example 0 .. 1, 0 .. 255, -32_768 .. 32_767) set the minimum number of bits any object of the type must occupy, plus a variable of each type. Main then prints each type's bounds and its 'Size via 'Image with Put_Line, with no loops, arithmetic or guards needed. About 20 lines.

## Language surface beyond today's Silver

Integers, ranged subtypes and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints each declared type's range and its resulting 'Size in bits with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413114 of the [task](https://rosettacode.org/wiki/Variable_size/Set) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
