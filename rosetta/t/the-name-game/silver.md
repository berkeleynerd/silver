# The Name Game

**Candidate: proofs likely to discharge automatically.** Everything is bounded character and slice work over a fixed-capacity buffer with explicit length guards, with no recursion, no loop-carried arithmetic beyond for-loop indexes, and no annotations needed.

Position 986 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

The name comes from the first argument into a fixed-capacity buffer with a length; a for loop validates that every character is a letter and a short helper normalizes case by 'Pos arithmetic on a copy (first letter upper, rest lower). A procedure Rhyme(Letter, Name) builds each of the three rhyming tails with if branches (vowel keeps the whole lowercased name, first letter equal to Letter drops it, else Letter plus the rest), and Put_Line prints the four verse lines, with the program rejecting empty, over-long or non-letter input. About 80 lines.

## Proof obligations to watch

- **index**: Slices of the name after the first letter are only taken after a guard that the length is at least 1 and at most the fixed buffer capacity, so bounds discharge.
- **length**: Each output line is built in a bounded buffer sized for the maximum name length (for example 32) times its few repetitions plus fixed text, so concatenation lengths are statically within capacity.

## Language surface recorded by this assessment

Characters, string indexing, string building, ranged subtypes, integers, Boolean objects, for loops, procedures, unconstrained arrays and conditional expressions.

## External effects

- **arguments** (allowed): The name is taken from the first command-line argument via Silver_Arguments.First_Or_Default.
- **console output** (allowed): The four lyric lines per verse are written with Put_Line.
- **exit status** (allowed): Invalid input (empty, too long or non-letter name) is rejected with a specified nonzero status.

Assessed on 2026-10-15 against page revision 413084 of the [task](https://rosettacode.org/wiki/The_Name_Game) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
