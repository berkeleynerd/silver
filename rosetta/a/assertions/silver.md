# Assertions

**Excluded from Silver: annotations.** The task asks only to show an assertion that an integer variable equals 42. That needs an assertion pragma or contract in the source, which Oracle rule 3 bans for good, so the task is excluded.

## Language surface recorded by this assessment

Integers.

## Oracle conflicts

- **annotations**: The task's sole requirement is to show the language's assertion construct (pragma Assert or an Assert aspect/contract) checking that an integer variable equals 42. Oracle rule 3 bans assertions and every pragma except SPARK_Mode (On) from program source. An explicit if-guard is ordinary control flow, not an assertion, so it does not meet the task.

Assessed on 2026-10-15 against page revision 414634 of the [task](https://rosettacode.org/wiki/Assertions) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
