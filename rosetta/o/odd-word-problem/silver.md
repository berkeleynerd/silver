# Odd word problem

**Candidate: proofs plausibly discharge automatically.** Every check follows from character comparisons and a ranged depth counter guarded before each recursive call, but the task's no-collection rule forces recursion, which is acceptable only with an explicit depth limit and rejection of longer words. This makes the outlook plausible rather than likely, since stack use rests on that documented limit.

Position 1555 in the [progression](../../progression.md#stage-34), in stage 34.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

A Read_Char procedure fetches one character from stdin (with an end-of-input flag that triggers rejection), and a main loop alternates between echoing an even word directly and handling an odd word with a recursive procedure Reverse_Word(C, Depth, Next) that reads the following character, recurses while letters continue, prints C on the way back, and returns the delimiter in an out parameter. Depth is a bounded subtype, guarded before each recursive call, and the loop stops after printing the full stop and a newline; no array or string stores characters. About 70 lines.

## Proof obligations to watch

- **stack**: Reversal without a collection needs recursion of depth equal to the word length, so the program carries an explicit Depth counter and rejects words longer than a documented limit (e.g. 255), making stack use a fixed bound.
- **range**: The Depth counter is a ranged subtype and a guard before each recursive call rejects when it would reach the limit, so the increment cannot fail.
- **termination**: Only procedures are used (loops and recursion in procedures get no termination check), and the reading loop is guarded by end-of-input rejection, so no variant is needed.
- **initialization**: The out parameter carrying the delimiter character back to the caller is assigned on every path through the recursive procedure.

## Language surface recorded by this assessment

Characters, Boolean objects, ranged subtypes, integers, procedures, functions, recursive procedures, while loops, Put without a newline, standard input and exit status.

## External effects

- **standard input** (allowed): Characters are read one at a time from standard input with no peeking, and end of input must be detected.
- **console output** (allowed): The transformed stream is written one character at a time without line terminators, plus a final newline.
- **exit status** (allowed): Malformed input (missing full stop, over-long word) is rejected through the existing Reject outcome.

Assessed on 2026-10-15 against page revision 412946 of the [task](https://rosettacode.org/wiki/Odd_word_problem) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
