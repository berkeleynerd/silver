# Transliterate English text using the Greek alphabet

**Candidate: proofs likely to discharge automatically.** All checks are string-index bounds that the loop condition and an explicit lookahead guard establish, with no nonlinear arithmetic, and the loop sits in a procedure so no variant is needed; the only new surface is Character handling, string indexing, case statements and Put.

Position 998 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Embed the task text as several String constants, one per output line, and pass each to a procedure Transliterate (Text : String) that scans with a while loop and index I. At each position it checks the next character through guarded lookahead (I < Text'Last) for the digraphs ch, kh, ph, ps, th, rh, ck, ee and oo, otherwise a case statement on the single letter, and it emits the angle-bracket Greek name with Put, using the capitalized name for upper-case letters. For s it looks ahead and emits sigma-final when the next character is absent or not a letter; any other character is passed through unchanged, and the line ends with Put_Line. About 170 lines.

## Proof obligations to watch

- **index**: The scan index is loop-carried in a while loop, but the loop condition I <= Text'Last gives the bound at each use, and the lookahead Text (I + 1) is guarded by I < Text'Last.
- **overflow**: Advancing I by 1 or 2 is guarded by the I <= Text'Last loop condition and an I < Text'Last test before the two-letter step, so I + 2 stays within Integer.

## Language surface beyond today's Silver

Characters, case statements, unconstrained arrays, string indexing, while loops, procedures, integers, Put without a newline and ranged subtypes.

## External effects

- **console output** (allowed): Prints each transliterated line with angle-bracket Greek letter names, using the task's allowed ASCII fallback.

Assessed on 2026-10-15 against page revision 412135 of the [task](https://rosettacode.org/wiki/Transliterate_English_text_using_the_Greek_alphabet) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
