# String prepend

**Candidate: proofs likely to discharge automatically.** The existing initialized-buffer composition performs a real multi-character prepend, with an exact fit followed by whole refusal. The expected stdout is Hello World!\nfull\nHello World!\n. Character stores, a bounded length, counted loops and prefix output already exist; bounded-string-building is precise Rosetta metadata and introduces no language rule. The linked capability record separates final delivery evidence from inherited planning observations.

Position 62 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main initializes all 12 buffer cells with logical text World! and spare spaces, a bounded Len counter, and the multi-character literal 'Hello '. In each of two attempts, one bare-name capacity guard checks that the entire literal fits. It shifts the existing characters right in reverse order by the literal length, then copies every literal character to the front with a counted loop. Only the successful arm updates Len. The first attempt exactly fills the buffer; the second prints full without changing buffer or length. Filled-prefix output remains after end if; both attempts print the variable, with the refused attempt preserving the previous prefix. About 26 lines.

## Proof obligations to watch

- **index**: The whole-literal guard bounds every counted copy destination; reverse shifting in prepend preserves unread source cells.
- **length**: Len remains in 0 .. 12; exact fit reaches capacity, and the full-buffer branch changes neither Len nor buffer before the unchanged prefix is printed.

## Language surface recorded by this assessment

Bounded String building with initialized buffers, bounded String indexing and Character operations, bounded mutable Integer objects, scalar guard refinement and Integer range for loops.

## External effects

- **console output** (allowed): Prints the resulting string with Put_Line.

Initially assessed on 2026-10-15 against page revision 413063 of the [task](https://rosettacode.org/wiki/String_prepend) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-18 by Codex through targeted source review; see the [review record](../../../docs/bounded-string-building-samples.md).
