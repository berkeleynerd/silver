# Idiomatically determine all the lowercase and uppercase letters

**Candidate: proofs likely to discharge automatically.** Every check (loop bounds, buffer index, Character'Val-free arithmetic) follows from the subtype ranges and a for loop over a static range, so proofs should discharge without annotations. The only new Silver surface is Character subtypes, for loops and String indexing, with no recursion, no floating point and no loop-carried values.

Position 481 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Declare subtypes Lower and Upper as Character ranges 'a'..'z' and 'A'..'Z', and two 26-character String variables initialised to a placeholder. A for loop over each subtype's range stores each letter at index Character'Pos(C) - Character'Pos(range first) + 1, then Put_Line prints "Lower: " & Lower_Buffer and "Upper: " & Upper_Buffer. No input is read, so there is no invalid-input path, and the character positions are derived from the language's own Character type rather than hardcoded for ASCII. About 22 lines.

## Proof obligations to watch

- **index**: Each buffer index is computed from the loop character's position minus the position of the range's first letter, which is safe because the loop variable is typed to the subtype Lower or Upper so the index lies in 1..26.

## Language surface beyond today's Silver

Characters, ranged subtypes, for loops, arrays, string indexing and integers.

## External effects

- **console output** (allowed): Prints the lowercase and uppercase letter lines with Put_Line.

Assessed on 2026-10-15 against page revision 415254 of the [task](https://rosettacode.org/wiki/Idiomatically_determine_all_the_lowercase_and_uppercase_letters) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
