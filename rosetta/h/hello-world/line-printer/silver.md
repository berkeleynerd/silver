# Hello world/Line printer

**Excluded from Silver: hardware.** The task needs to write the line "Hello World!" to an attached line printer device, which is a hardware effect that Silver lacks today. It breaks no fixed Oracle rule, because a future admitted library operation could specify printer access along with its failure outcome (printer missing or unavailable).

## External effects

- **hardware** (not allowed): The task requires sending a line of text to a physical line printer device (for example /dev/lp0), which is a hardware device and not standard output.

Assessed on 2026-10-15 against page revision 415268 of the [task](https://rosettacode.org/wiki/Hello_world/Line_printer) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
