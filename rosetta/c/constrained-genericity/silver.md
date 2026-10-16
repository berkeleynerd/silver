# Constrained genericity

**Candidate: proofs likely to discharge automatically.** Ada's generic formal subprogram expresses the eatable constraint directly without tagged types, and GNATprove analyses each instance, where the only checks are a count increment and index guarded by Count < Capacity, so proof should discharge without annotations.

Position 1528 in the [progression](../../progression.md#stage-31), in stage 31.

## Approach

A generic package Food_Boxes takes a private Food type, a formal procedure Eat (Item : in out Food) that is the eatable constraint and is never called, an Empty filler value and a static capacity, and declares a Box record holding a fixed array of Food plus a count ranged 0 .. Capacity. Add stores an item only when Count < Capacity and reports the outcome through a Boolean out parameter, so a full box is a visible rejection. Main declares an example record type Banana with its own Eat procedure, instantiates Food_Boxes for it, adds a few bananas and prints a line for each accepted or rejected add. About 55 lines.

## Proof obligations to watch

- **initialization**: The box's array of a formal private element type has no default value, so the generic takes an Empty formal object to initialize every slot by aggregate, and flow analysis then sees it fully initialized.
- **index**: Add writes Items (Count + 1) only after testing Count < Capacity, with Count declared in 0 .. Capacity, so the index and range checks follow from that guard.

## Language surface recorded by this assessment

Generics, packages, records, arrays, integers, ranged subtypes, Boolean objects and procedures.

## External effects

- **console output** (allowed): The program prints lines confirming that the example eatable items were stored in their food box.

Assessed on 2026-10-15 against page revision 414128 of the [task](https://rosettacode.org/wiki/Constrained_genericity) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
