# String append

**Candidate: proofs likely to discharge automatically.** The existing initialized-buffer composition performs a real multi-character append, with an exact fit followed by whole refusal. The expected stdout is Hello, world!\nfull\nHello, world!\n. Character stores, a bounded length, counted loops and prefix output already exist; bounded-string-building is precise Rosetta metadata and introduces no language rule. The linked capability record separates final delivery evidence from inherited planning observations.

Position 51 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main initializes all 13 buffer cells with logical text Hello and spare spaces, a bounded Len counter, and the multi-character literal ', world!'. In each of two attempts, one bare-name capacity guard checks that the entire literal fits. The successful arm saves the guarded length in Start (declared 0 .. 5) and updates Len before entering the counted copy loop. Start keeps each destination bounded when loop-body analysis widens mutable facts; the loop copies every literal character after the original used prefix. Only the successful arm updates Len. The first attempt exactly fills the buffer; the second prints full without changing buffer or length. Filled-prefix output remains after end if; both attempts print the variable, with the refused attempt preserving the previous prefix. About 23 lines.

## Proof obligations to watch

- **index**: The bare Len guard reserves room for the entire literal before the counted Character stores.
- **length**: Len remains in 0 .. 13; exact fit reaches capacity, and the full-buffer branch changes neither Len nor buffer before the unchanged prefix is printed.

## Language surface recorded by this assessment

Bounded String building with initialized buffers, bounded String indexing and Character operations, bounded mutable Integer objects, scalar guard refinement and Integer range for loops.

## External effects

- **console output** (allowed): The program prints the string after the append with Silver_IO.Put_Line.

Initially assessed on 2026-10-15 against page revision 413057 of the [task](https://rosettacode.org/wiki/String_append) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-18 by Codex through targeted source review; see the [review record](../../../docs/bounded-string-building-samples.md).
