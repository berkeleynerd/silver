# Parse an IP Address

**Candidate: proofs plausibly discharge automatically.** Every check can be discharged by guards placed just before the operation and by static array bounds, with no annotations needed. However, the parser has many loop-carried counters and accumulators, and the '::' expansion uses index arithmetic, so discharge depends on careful program shape. That makes the outlook plausible rather than likely.

Position 1106 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

A Parse_And_Print procedure takes each embedded address string and scans it once with a for loop over S'Range as a small state machine: it detects an optional leading '[' and the ']:' or trailing ':port' (only for IPv4 or bracketed IPv6), accumulates IPv4 octets or IPv6 16-bit groups into fixed arrays (8 groups, with the '::' position recorded and later expanded by shifting), and handles an embedded dotted quad as the last two groups. Every accumulator and counter is guarded before use, so a bad character, an oversize field or too many groups prints "Invalid Address". Valid results are written as fixed-width hex (8 digits for IPv4, 32 for IPv6) from a hex-digit table, followed by the address space and the port through 'Image or "not specified". About 170 lines.

## Proof obligations to watch

- **overflow**: Octet, hex-group and port accumulators are loop-carried, so each multiply-add is preceded by a guard (value <= 255, group digit count < 4, port <= 6553) that rejects the input visibly as invalid when exceeded.
- **index**: Group and octet counters written into fixed arrays of 8 groups and 4 octets are loop-carried, so each store is guarded by a count-below-capacity test whose failure marks the address invalid.
- **range**: Expanding '::' shifts the trailing groups right by 8 minus the group count, which needs the shift index computed from guarded counters stored in ranged subtypes so the target index provably stays in 0 .. 7.
- **length**: The 32-character hex output buffer is filled through a for loop over a static index range with each nibble obtained by / and mod 16, so lengths follow from static bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, unconstrained arrays, string indexing, string building, 'Image of scalars, for loops, procedures and functions.

## External effects

- **console output** (allowed): Prints each embedded address with its hexadecimal address number, address space and port (or that none was given).

Assessed on 2026-10-15 against page revision 413833 of the [task](https://rosettacode.org/wiki/Parse_an_IP_Address) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
