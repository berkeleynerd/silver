# Selectively replace multiple instances of a character within a string

**Candidate: proofs likely to discharge automatically.** The fixed loop keeps all indexed reads and writes within 1..11. The current byte is captured before mutation, and occurrence counters implement the requested selection instead of hardcoding final positions or output. Guards establish counter range containment using the existing scalar-flow rules. The exact program passed the complete Linux manifest-driven regression check; complete native and actual-source assurance is recorded in docs/bounded-string-characters.md.

Position 82 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The driver samples/rosetta_selective_character_replacement.adb scans the task String abracadabra once. A Character snapshot selects one of three bounded occurrence counters. It replaces a occurrences 1,2,4,5 by A,B,C,D, b occurrence 1 by E and r occurrence 2 by F; all other bytes remain. It prints the task-required AErBcadCbFD. Each counter increment is guarded by its declared maximum. About 42 lines.

## Proof obligations to watch

- **range**: Each occurrence counter is incremented only under a direct comparison with its declared maximum (5 for a, 2 for b and r).

## Language surface recorded by this assessment

Bounded String indexing and Character operations, bounded mutable Integer objects, scalar guard refinement and Integer range for loops.

## External effects

- **console output** (allowed): Prints the computed result or verdict with Silver_IO.Put_Line.

Initially assessed on 2026-10-15 against page revision 413011 of the [task](https://rosettacode.org/wiki/Selectively_replace_multiple_instances_of_a_character_within_a_string) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-04 by Codex through targeted source review; see the [review record](../../assessment-bounded-string-characters-20261031.md).
