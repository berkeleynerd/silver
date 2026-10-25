# Pangram checker

**Candidate: proofs likely to discharge automatically.** Every check follows from for-loop indexes over the string's own range and from character-range guards placed just before computing the letter index, and for loops need no termination annotation.

Position 964 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

A function Is_Pangram takes an unconstrained String and fills a Boolean array indexed by a 0..25 subtype, using a for loop over Text'Range and, for each character, an if guard on 'a'..'z' and 'A'..'Z' that computes the index from Character'Pos differences. A second for loop over the array checks that every letter was seen. A small procedure prints TRUE or FALSE for each of four embedded example sentences, including non-pangrams. About 45 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, unconstrained arrays, string indexing, for loops, functions and procedures.

## External effects

- **console output** (allowed): Prints TRUE or FALSE for each embedded example sentence with Put_Line.

Assessed on 2026-10-15 against page revision 412955 of the [task](https://rosettacode.org/wiki/Pangram_checker) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
