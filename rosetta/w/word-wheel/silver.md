# Word wheel

**Candidate: proofs likely to discharge automatically.** Every check follows from small array bounds, a 0..9 count subtype and guards placed immediately before each decrement or index, and the while loop is in a procedure so there is no termination obligation; the only new needs are line-by-line file reading and character-indexed arrays.

Position 1319 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

Embed the wheel string as a constant and, for each dictionary line read into a bounded 64-character buffer by a while loop in the Main procedure, reset a 26-entry array of letter counts from the wheel. A for loop over the word's characters decrements counts under explicit guards (lowercase letter, count above zero), tracks whether the central letter k was seen, and prints the word via a slice of the buffer if it has 3 to 9 letters, all consumed, and contains k. A missing or unreadable file produces a specified rejection message; the optional nine-letter grid search is omitted. About 70 lines.

## Proof obligations to watch

- **index**: Letter counts are indexed by Character'Pos minus 'a', which is discharged by a guard that the character lies in 'a'..'z' before each use, with non-lowercase words treated as non-matches.
- **range**: The per-letter available count is a subtype 0..9 and is decremented only after a guard that it is greater than zero, so the loop-carried counts stay in type range.
- **length**: Dictionary lines are read into a fixed bounded buffer with a reported length, and lines longer than the buffer are rejected as non-matches since they exceed nine letters, so no truncation changes a result.
- **initialization**: The counts array is rebuilt from the wheel string for every word by a full for loop over the array's own range, and the file-open failure has a specified rejection outcome.

## Language surface recorded by this assessment

Ranged subtypes, integers, characters, arrays, string indexing, for loops, while loops, procedures, Boolean objects, file input and text parsing.

## External effects

- **files** (allowed): The dictionary unixdict.txt must be read line by line from a named file.
- **console output** (allowed): Each matching word is printed on its own line.

Assessed on 2026-10-15 against page revision 414586 of the [task](https://rosettacode.org/wiki/Word_wheel) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
