# Order disjoint list items

**Candidate: proofs likely to discharge automatically.** All loops are for loops over fixed array ranges and all indexes come from subtype ranges or guards just before use, so no annotations are needed; only the loop-carried counters need routine guards.

Position 610 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Words are fixed-length 3-character padded Strings held in a record with a fixed-capacity array (capacity 16) and a count, with the seven test cases embedded as aggregates. A procedure Order_Disjoint marks, for each N word in order, the first unused equal M position in nested for loops (reporting a visible 'DomainError' outcome and leaving M unchanged if any N word is not found), then a second for loop over M copies successive N words into the marked positions using a guarded next-index counter. Another procedure builds each output line in a bounded buffer with explicit capacity guards and prints it with Put_Line. About 130 lines.

## Proof obligations to watch

- **index**: The write cursor for the output line and the next-N counter are loop-carried, so each gets a guard (capacity check and count check) immediately before its array or slice use.
- **range**: The Count fields and N index live in subtypes bounded by the fixed capacity, and increments are guarded so the new value stays within the subtype.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, for loops, while loops and procedures.

## External effects

- **console output** (allowed): Each of the seven required cases prints its M, N and resulting M' lines via Put_Line.

Assessed on 2026-10-15 against page revision 412024 of the [task](https://rosettacode.org/wiki/Order_disjoint_list_items) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
