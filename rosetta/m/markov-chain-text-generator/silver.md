# Markov chain text generator

**Candidate: proofs plausibly discharge automatically.** Every array index and counter can be kept safe with declared ranges, for-loop bounds, and capacity or non-zero guards placed just before the operation, and no while loop or recursion appears inside a function. Several loop-carried counters each need careful guarding, though, so discharge depends on the program's shape.

Position 1455 in the [progression](../../progression.md#stage-28), in stage 28.

## Failure paths to test

- **further arguments**: too few or too many arguments, and an empty or invalid argument.
- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

Main validates three arguments (the file name, N in 1 .. Max_N and an output length in 1 .. Max_Out), then reads the file and splits it into words. Each word goes into a fixed-capacity array of records, each a bounded String plus a length, and the program rejects the input if the file has too many words, a word is too long, or there are no more than N words. Generation picks a starting prefix with a fixed-seed Lehmer generator. For each output word, one for-loop scan counts every position whose N words match the current prefix, and a second scan picks a pseudo-randomly chosen match and prints its suffix with Put. Generation stops when the prefix has no suffix or the requested length is reached. About 170 lines.

## Proof obligations to watch

- **index**: Word storage uses an array of records, each holding a fixed-width String and a length subtype 0..Max_Word_Len; the word count, character count and output count are loop-carried, so each increment is guarded by an explicit capacity test that rejects overlong words or oversized files with a visible message.
- **index**: Prefix-match scans use for loops with I in 1 .. Count - N and J in 0 .. N - 1, so I + J stays below Count by linear reasoning from the loop bounds, and N is validated against Max_N before use.
- **overflow**: The deterministic Lehmer generator keeps its state in a subtype 1 .. 2**31 - 2 and multiplies by 48271 in a 64-bit type, so the product cannot overflow and the mod result fits back in the state subtype.
- **division**: Choosing the r-th matching suffix uses mod by the candidate count, which is executed only inside a guard that the count is positive; a zero count ends generation as the task specifies.
- **range**: The selected candidate index is loop-carried through a second scan, so it is initialised to a valid word index and assigned only from the for-loop index, keeping it in range without an invariant.
- **stack**: The fixed-capacity word table is a static resource limit, so its stack or static storage is a fixed environmental premise rather than input-dependent growth.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, for loops, while loops, procedures, functions, Put without a newline, further arguments, text parsing and file input.

## External effects

- **console output** (allowed): The generated text is printed to standard output.
- **arguments** (allowed): The training-file name, prefix size N and output length in words are passed as command-line arguments, as the task suggests.
- **files** (allowed): The training text is read from a named text file.

Assessed on 2026-10-15 against page revision 415191 of the [task](https://rosettacode.org/wiki/Markov_chain_text_generator) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
