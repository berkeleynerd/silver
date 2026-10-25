# Sort the letters of string in alphabetical order

**Candidate: proofs likely to discharge automatically.** Every index is a for-loop variable over the string's own static bounds (the outer loop stops at S'Last - 1 and the inner loop starts at I + 1), and Character comparison and swap cannot fail a check, so all obligations follow from declarations and loop ranges.

Position 1524 in the [progression](../../progression.md#stage-31), in stage 31, which adds block statements.

## Approach

Main embeds the example sentence in a fixed-length String variable, prints it, then sorts it in place with a selection sort made of two nested for loops over the string's own index range, swapping out-of-order Characters through a Character temporary. The sorted string is printed with Put_Line, preserving case and spaces; no recursion, no loop-carried values besides the string itself. About 22 lines.

## Language surface recorded by this assessment

Characters, string indexing, for loops and block statements.

## External effects

- **console output** (allowed): Prints the original and the sorted string with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 405839 of the [task](https://rosettacode.org/wiki/Sort_the_letters_of_string_in_alphabetical_order) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
