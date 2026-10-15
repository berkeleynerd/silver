# Assertions in design by contract

**Excluded from Silver: annotations.** Not a candidate: the task's whole point is to write assertions or contracts (preconditions, postconditions, invariants) in the source as documentation. Oracle rule 3 bans author-written proof annotations and assertions, so this conflicts with a fixed rule.

## Language surface beyond today's Silver

Subprograms.

## Oracle conflicts

- **annotations**: The task is to show assertions (preconditions, postconditions, invariants) written in program source as documentation. Oracle rule 3 forbids authors from writing Pre/Post, invariants, assertions or any pragma except SPARK_Mode (On), so no Silver program can meet this task.

Assessed on 2026-10-15 against page revision 405482 of the [task](https://rosettacode.org/wiki/Assertions_in_design_by_contract) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
