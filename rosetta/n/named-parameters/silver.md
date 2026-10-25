# Named parameters

**Candidate: proofs likely to discharge automatically.** Ada's named and default parameter associations meet the task directly, and the only checks are concatenations of a literal with a bounded 'Image result, which prove trivially, so discharge is likely.

Position 49 in the [progression](../../progression.md#stage-2), in stage 2.

## Approach

A nested procedure Show (Arg_1 : Integer; Arg_2 : Integer := 0) prints "Arg_1 =" & Integer'Image (Arg_1) and the same for Arg_2 with Silver_IO.Put_Line. Main calls it positionally, with the default omitted, with named associations in reversed order, and with only the named first argument, so the output shows that the bindings are the same each time. The program has no loops, arithmetic or input, so no guards are needed. About 25 lines.

## Language surface recorded by this assessment

Integers, 'Image of scalars and procedures.

## External effects

- **console output** (allowed): Each call prints the values bound to its named parameters so the reader can see that the bindings are the same.

Assessed on 2026-10-15 against page revision 411871 of the [task](https://rosettacode.org/wiki/Named_parameters) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
