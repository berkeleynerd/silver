# Sorting algorithms/Sleep sort

**Excluded from Silver: delay.** Sleep sort starts one task per command-line integer, and each task delays in proportion to its value before printing it. This needs tasking, delay, arguments and console output. Bounded argument counts, validated integer parsing and a bounded value range fit Silver's rules, and nothing in the task breaks a fixed Oracle rule.

## Language surface beyond today's Silver

Tasking, integers, arrays, loops, subprograms and string operations.

## External effects

- **arguments** (allowed): The non-negative integers to sort are read from the command line.
- **console output** (allowed): The sorted integers are printed.
- **delay** (not allowed): Each task sleeps for an interval proportional to its item's value before emitting it.

Assessed on 2026-10-15 against page revision 413043 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Sleep_sort) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
