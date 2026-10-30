# XML validation

**Candidate: proofs plausibly discharge automatically.** No Oracle rule forbids the program, but it is a fairly large one. Its many loop-carried cursors, tree indices and counters each need a guard just before use, since no invariant can be written. That makes discharge depend on careful program shape, though no annotation is needed.

Position 1200 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

The W3Schools shiporder XML and XSD are embedded as String constants, and each is parsed by a hand-written scanner into a fixed-capacity array of node records (name buffer, kind, attributes, parent, first-child and next-sibling indices). The program validates against a defined XSD subset: element, complexType, sequence, attribute with use=required, minOccurs/maxOccurs including unbounded, and the simple types xs:string, xs:decimal, xs:integer and xs:positiveInteger, which are checked lexically. It walks the schema and document trees together using an explicit work stack inside procedures, and every limit or malformed-input case prints a specified rejection message. About 650 lines.

## Proof obligations to watch

- **index**: The scanner cursor into the XML and XSD text is a loop-carried value, so every character read needs a guard of the form Pos <= Text'Last just before it, with end of text reported as a malformed-document outcome.
- **range**: Node, child and stack indices into the fixed-capacity tree and work-stack arrays come out of while loops, so each store must be guarded by a count-below-capacity test that rejects documents that exceed the documented limits.
- **overflow**: Occurrence counters compared with minOccurs and maxOccurs (unbounded) are bounded by the node capacity, and an explicit guard placed before each increment keeps them inside their declared range.
- **length**: Copying element names and text values into bounded name buffers needs a length guard before each slice assignment, and any name that is too long is rejected visibly.
- **termination**: All scanning and tree walking happen in while loops inside procedures, which get no termination check, while the helper functions use only for loops.
- **stack**: Nested element validation uses an explicit array stack in place of recursion, so stack depth is fixed and does not grow with the input.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, enumerations, arrays, records, unconstrained arrays, string indexing, string building, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): The program prints whether the embedded XML document is valid against the embedded XSD schema, naming the first violation found.

Assessed on 2026-10-15 against page revision 375434 of the [task](https://rosettacode.org/wiki/XML_validation) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
