# Memory layout of a data structure

**Candidate: proofs likely to discharge automatically.** Every component is a static one-bit modular value assigned from literals in an aggregate, so the only checks are routine initialization and range checks that follow from the declarations. The open question is admitting representation clauses in Silver, not provability.

Position 1269 in the [progression](../../progression.md#stage-23), in stage 23.

## Approach

Declare a one-bit modular type Bit and a record Rs_232_Layout with nine Bit components for the 9-pin signals, placed with a record representation clause at fixed bit positions 0 to 8 and a size clause. Main builds a constant aggregate of that record and prints each signal name with its value through Silver_IO.Put_Line and 'Image, with no loops, arithmetic or input. About 40 lines.

## Proof obligations to watch

- **other**: The task's core requirement is a record representation clause (and a 'Size clause), an ordinary Ada declaration that SPARK accepts but that Silver's surface catalogue does not yet name, so admitting it is a language-design decision rather than a proof obligation.

## Language surface beyond today's Silver

Modular types, records and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints each named pin's bit position and a sample value so the defined layout is observable.

Assessed on 2026-10-15 against page revision 414338 of the [task](https://rosettacode.org/wiki/Memory_layout_of_a_data_structure) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
