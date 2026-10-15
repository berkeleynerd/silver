# Honeycombs

**Excluded from Silver: GUI, hardware.** The task requires an interactive windowed UI with hexagon widgets, mouse and keyboard selection, and colour changes. These are external effects Silver lacks (gui, hardware, stdin), not rule conflicts. A deterministic pseudo-random generator can supply the unique letters, and the state fits in bounded arrays of records.

## Language surface beyond today's Silver

Arrays, records, loops, subprograms, characters, enumerations, integers and floating point.

## External effects

- **GUI** (not allowed): The task requires 20 hexagon widgets in a window with colour changes on selection, which is a GUI.
- **standard input** (allowed): The program waits for the user to press a key matching a hexagon's letter.
- **hardware** (not allowed): Selecting a hexagon with a pointing device (mouse click) is required on platforms that support one.

Assessed on 2026-10-15 against page revision 414956 of the [task](https://rosettacode.org/wiki/Honeycombs) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
