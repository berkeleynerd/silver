# Order by pair comparisons

**Candidate: proofs plausibly discharge automatically.** All checks come from small ranged subtypes, a fixed capacity of 7 and guards before each index update, and the while loop sits in a procedure so no termination proof is needed; the careful shape of the loop-carried binary-search bounds keeps this at plausible rather than likely.

Position 1350 in the [progression](../../progression.md#stage-23), in stage 23.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

The seven colours are embedded as an enumeration (or index 1..7 with a case-based name printer) in the unordered input order, and a sorted array of at most 7 entries is built by binary insertion, which asks about ceil(log2(k+1)) comparisons per new item. Each comparison prints a prompt, reads one line from stdin, and maps it to less, equal or greater, rejecting anything else; an equal answer inserts next to the matching item, and elements above the insertion point are shifted with a reverse for loop. The binary-search loop is a while loop inside a procedure with ranged lo/hi indexes and explicit guards before every index and update. About 90 lines.

## Proof obligations to watch

- **index**: Binary-insertion bounds lo, mid and hi are loop-carried, so they are declared in a ranged subtype 0..7 and mid is computed only under an explicit lo <= hi guard so the array index check discharges from types.
- **range**: Updating hi := mid - 1 and lo := mid + 1 must stay within the subtype, which needs guards such as mid > 1 before subtracting and mid < 7 before adding.
- **initialization**: The sorted array is fully initialized by an aggregate and the shift loop runs over the array's own range, so flow analysis is routine.
- **other**: Reading each answer requires a specified outcome for end of input or an unrecognized response (reject with exit status), which depends on an admitted stdin library operation with a documented failure result.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, enumerations, arrays, case statements, for loops, while loops, procedures, Put without a newline, standard input, exit status and string building.

## External effects

- **console output** (allowed): Prompts for each pair and the final ordered list are printed.
- **standard input** (allowed): The user's answer to each pair comparison (less, equal or greater) is read as a line from standard input.
- **exit status** (allowed): Invalid or missing answers are rejected with a specified nonzero exit status.

Assessed on 2026-10-15 against page revision 412948 of the [task](https://rosettacode.org/wiki/Order_by_pair_comparisons) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
