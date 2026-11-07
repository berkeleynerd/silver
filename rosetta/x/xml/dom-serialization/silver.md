# XML/DOM serialization

**Candidate: proofs likely to discharge automatically.** The task is a tiny fixed three-node tree serialized to console, which needs only bounded arrays, records and guarded for-loop appends with no annotations, so proofs should discharge routinely.

Position 798 in the [progression](../../../progression.md#stage-13), in stage 13.

## Approach

Represent the DOM as a fixed-capacity array of node records (kind, parent index, bounded name or text held in a fixed-size String with a length field) built by a procedure that adds root, element and text nodes. A non-recursive serializer procedure walks the nodes in document order using a for loop over the node array and the stored depth, appending the XML declaration, indented tags and text into a bounded buffer with a capacity guard before each append, then prints it with Put_Line per line. About 110 lines.

## Proof obligations to watch

- **index**: Appending into the fixed-capacity output buffer is guarded by a length check against the capacity, with an overflow outcome of rejecting the document, and child and node indexes come from for-loops over the arrays' own ranges.
- **range**: The buffer length counter is loop-carried, so each append checks remaining capacity just before writing so the counter stays within its subtype.

## Language surface recorded by this assessment

Characters, ranged subtypes, arrays, records, for loops, case statements, procedures, functions, string indexing, string building and Put without a newline.

## External effects

- **console output** (allowed): The serialized XML text is written to standard output.

Assessed on 2026-10-15 against page revision 413256 of the [task](https://rosettacode.org/wiki/XML/DOM_serialization) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
