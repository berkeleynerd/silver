# Process SMIL directives in XML data

**Candidate: proofs plausibly discharge automatically.** The program needs only bounded text scanning, scaled-integer arithmetic and string building, all of which can be guarded explicitly, though many loop-carried positions and accumulators need careful guards.

Position 1144 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed the SMIL document as a String constant, then scan it with bounded while loops in procedures to locate each animate tag and parse its attributeName, from, to, begin and dur values into scaled-integer (thousandths) triples held in small fixed arrays. For each time (0 and 2) interpolate each component with integer arithmetic under range-bounded subtypes, then emit the XML with the smil wrapper and animate children removed, writing attribute values through a bounded buffer with trailing zeros trimmed. Malformed input (missing quotes, too many animations, out-of-range numbers) takes an explicit Reject path. About 260 lines.

## Proof obligations to watch

- **index**: Scanning loops advance a position through the text, so every String index is guarded by an explicit bound test just before use.
- **overflow**: Scaled-integer interpolation multiplies a difference by time, which is discharged by parsing values into small ranged subtypes so the product cannot overflow.
- **length**: Output attribute strings are built in bounded buffers with explicit capacity guards before each append, rejecting input that would exceed them.
- **termination**: All scanning loops are while loops placed in procedures, which get no termination check, and parsing helpers that return values are written as procedures with out parameters.
- **range**: Decimal parsing and formatting of values like 0.56 depend on digit-by-digit accumulation whose loop-carried values need guards or capped subtype ranges.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, records, string indexing, string building, 'Image of scalars, text parsing, for loops, while loops, procedures, functions and case statements.

## External effects

- **console output** (allowed): The program prints the transformed XML for t = 0 and t = 2 seconds.

Assessed on 2026-10-15 against page revision 406920 of the [task](https://rosettacode.org/wiki/Process_SMIL_directives_in_XML_data) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
