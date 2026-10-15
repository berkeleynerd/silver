# Word wrap

**Candidate: proofs plausibly discharge automatically.** The greedy wrap is plain index scanning over a constant string inside a procedure with while loops, so checks follow from guards before each index and slice, but several loop-carried indices need careful guard placement without invariants. No annotation-only facts, recursion or heap are needed, so discharge is plausible rather than certain.

Position 1009 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Embed the task paragraph as a String constant and write one procedure Wrap(Text, Width) that implements the greedy algorithm by index arithmetic: skip spaces, find the end of the next word, and either extend the current line or print the slice Text(Line_Start .. Line_End) and start a new line. Main calls it at two widths (for example 72 and 40), with guards before every index or slice and an over-long word emitted alone on its line; no line buffer or Unbounded strings are needed. The Knuth-Plass extra credit is omitted and stdin reading is not required. About 70 lines.

## Proof obligations to watch

- **index**: Word-scanning indices are loop-carried in while loops, so each Text(I) access and each Text(Start .. Stop) slice is preceded by an explicit guard such as I <= Text'Last and Start <= Stop.
- **overflow**: Index and line-length arithmetic stays within Natural bounds because the text is a fixed-size constant and the width parameter is a small ranged subtype, though loop-carried sums need guards.
- **termination**: The scanning loops live in a procedure, which gets no termination check, and each iteration advances an index.
- **other**: A word longer than the wrap width is placed alone on its own over-long line, which is the specified visible outcome rather than a truncation or error.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, string indexing, unconstrained arrays, Boolean objects, while loops and procedures.

## External effects

- **console output** (allowed): Wrapped lines of the embedded sample paragraph are printed with Silver_IO.Put_Line at two wrap columns.

Assessed on 2026-10-15 against page revision 411840 of the [task](https://rosettacode.org/wiki/Word_wrap) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
