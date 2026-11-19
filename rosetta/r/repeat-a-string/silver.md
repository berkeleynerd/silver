# Repeat a string

**Candidate: proofs likely to discharge automatically.** The repeat-five example builds hahahahaha in initialized storage and prints its used prefix. The declared count domain remains 0 .. 10; the planning boundary run executed all eleven counts, including empty and exact-capacity output. Existing String/Character stores, Integer bounds, counted loops and prefix output provide this bounded composition without a new language rule. Final-input application and boundary evidence is separate in the linked capability record.

Position 39 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main declares Source as the literal ha, a fully initialized 20-cell String buffer, Count : Integer range 0 .. 10 := 5, and Len in 0 .. 20. Nested counted loops copy Source (J) to (((I - 1) * 2) + J), then Len := (Count * 2) and Put_Line prints Buffer (1 .. Len). The primary result is hahahahaha followed by LF; separate boundary coverage exercises zero and maximum counts. The optional repeat-character variant and String-valued functions are not required. About 19 lines.

## Proof obligations to watch

- **index**: Over the full Count domain 0 .. 10, I lies in 1 .. 10 and J in 1 .. 2, so every copy destination lies in 1 .. 20.
- **length**: Count * 2 lies in 0 .. 20. Zero iterations give the empty prefix and Count 10 gives exact capacity; Count 5 is the delivered primary result.

## Language surface recorded by this assessment

Bounded String building with initialized buffers, bounded String indexing and Character operations, bounded mutable Integer objects and Integer range for loops.

## External effects

- **console output** (allowed): Prints the repeated strings with Put_Line.

Initially assessed on 2026-10-15 against page revision 411533 of the [task](https://rosettacode.org/wiki/Repeat_a_string) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-18 by Codex through targeted source review; see the [review record](../../../docs/bounded-string-building-samples.md).
