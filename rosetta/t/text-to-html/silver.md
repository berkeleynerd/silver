# Text to HTML

**Candidate: proofs likely to discharge automatically.** Every access is a for-loop index over the constant text's own range or is preceded by an explicit length guard, and all work is in procedures with no function loops, so no variant or invariant is needed.

Position 539 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The sample plain text is an embedded String constant with LF-separated paragraphs; one for loop over Text'Range accumulates paragraph start and end indices (in a subtype bounded by the text length) and calls a procedure when a blank-line boundary or the end is reached. That procedure classifies the paragraph (leading-space title, '*' bullet, digit-and-dot numbered item, otherwise plain), updates two Boolean list-open flags, and emits tags with Put/Put_Line while a character-escaping procedure writes &amp;, &lt;, &gt;, &quot; and &#39; for each character via a for loop over the paragraph slice; open lists are closed at the end. About 130 lines.

## Proof obligations to watch

- **index**: Paragraph start and end positions are loop-carried, so the program keeps them in a subtype bounded by the text's own range and guards each look-ahead (such as the character after a digit) with an explicit length test just before the access.
- **overflow**: Position counters are bounded by the fixed constant text length, so +1 steps are protected by the declared subtype range and a guard against the last index.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, string indexing, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The program writes the generated XHTML document to standard output.

Assessed on 2026-10-15 against page revision 389207 of the [task](https://rosettacode.org/wiki/Text_to_HTML) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
