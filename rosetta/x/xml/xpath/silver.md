# XML/XPath

**Candidate: proofs plausibly discharge automatically.** The task reduces to substring search over a fixed embedded document with a handful of bounded scans, so every index check follows from for-loop ranges and explicit length guards. Plausible rather than likely because the careful position arithmetic across several scan phases needs guards on each loop-carried offset.

Position 556 in the [progression](../../../progression.md#stage-10), in stage 10.

## Approach

The XML document is embedded as a constant String, and a Find_Tag-style helper procedure scans it with a for loop over the string's own index range, comparing a guarded slice against an open tag and then locating the matching close tag. Three scans print the first item element (from the first open tag through its close tag), the text between each price tag pair, and each name element, using Put_Line for output and Put for inline text. A missing close tag is handled by an explicit visible outcome of stopping the scan with an error message. About 90 lines.

## Proof obligations to watch

- **index**: Every slice or character access during tag matching is preceded by an explicit guard that the tag length fits within the remaining document, and the scan position is a for-loop index over the document's own range.
- **overflow**: Positions are subtype-bounded to the document length so the arithmetic computing end offsets stays within the declared range.
- **termination**: All scanning is in a procedure using for loops, so no variant is needed and no function contains a while loop.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing, for loops, while loops, procedures, functions, Boolean objects and Put without a newline.

## External effects

- **console output** (allowed): Prints the first item element, each price text and each name element to standard output.

Assessed on 2026-10-15 against page revision 415325 of the [task](https://rosettacode.org/wiki/XML/XPath) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
