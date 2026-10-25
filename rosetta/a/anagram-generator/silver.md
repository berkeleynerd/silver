# Anagram generator

**Candidate: proofs plausibly discharge automatically.** Every check can follow from declared ranges and guards placed just before use, but several loop-carried values (word count, letter counters, line length) each need an explicit guard and file failure needs a specified outcome, so discharge depends on careful program shape rather than annotations.

Position 1329 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

A procedure reads unixdict.txt line by line in a while loop into a fixed-capacity array of records (bounded character buffer, length, and a 26-element letter-count array), keeping only all-lowercase-letter words whose counts fit within the seed's counts. For each embedded seed (e.g. Purefox, Petelomax) the program computes its letter counts, then uses nested for loops over the candidate pairs and prints those whose summed counts equal the seed's, building each output line by concatenating slices. Guards on character range, buffer length, capacity and counter bounds lead to visible skip or reject outcomes. About 170 lines.

## Proof obligations to watch

- **overflow**: Per-letter counters incremented in a for loop over a word are loop-carried, so each increment needs a guard against the counter type's upper bound that rejects the word visibly if reached.
- **index**: Indexing the letter-count array by a Character discharges only after a guard that the lowercased character lies in 'a' .. 'z', with other characters skipped as the task permits.
- **length**: Dictionary lines are read into a fixed buffer and words longer than the documented maximum, or beyond the documented word capacity, must be skipped or reported by explicit guards rather than truncated.
- **range**: The stored-word count is loop-carried across the file-reading while loop, so appending needs a guard against the fixed capacity just before the store.
- **other**: Opening or reading the word file can fail, so the program needs an admitted file library with specified failure outcomes and must report a missing file visibly.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, records, unconstrained arrays, string indexing, string building, for loops, while loops, procedures, functions and file input.

## External effects

- **console output** (allowed): Prints each seed and the two-word anagrams found for it.
- **files** (allowed): The task requires reading a public word list such as unixdict.txt from a named file.

Assessed on 2026-10-15 against page revision 415145 of the [task](https://rosettacode.org/wiki/Anagram_generator) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
