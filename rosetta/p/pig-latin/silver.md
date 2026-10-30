# Pig Latin

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded index subtypes and guards placed just before each buffer access, with no loop-carried fact needing an invariant, though the guard-heavy shape of the scanning loops needs care.

Position 543 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

An embedded sentence constant is scanned by a while loop in a procedure that copies non-letters through and, for each word, copies the leading consonants into a small bounded buffer, then the remainder of the word, then the consonants plus "ay" (or "way" when it starts with a vowel), into a fixed-capacity output buffer. Positions are range-typed and every buffer access is guarded by an explicit capacity check with a visible rejection outcome, and the result is printed with Put_Line. About 70 lines.

## Proof obligations to watch

- **index**: The read position and output length are loop-carried, so each is a range-typed variable and every read or write is preceded by an explicit bound guard that stops the word loop.
- **length**: The output buffer has fixed capacity sized for the embedded sentence plus 3 extra characters per word, and a guard rejects any word that would overflow it with a specified message.
- **overflow**: Position and length counters are bounded subtypes of small capacity so increments are guarded and cannot overflow.
- **termination**: The word-scanning loops are in a procedure, which has no termination check, and each advances the position by at least one.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, string indexing, string building, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The program prints the Pig Latin sentence to standard output.

Assessed on 2026-10-15 against page revision 415138 of the [task](https://rosettacode.org/wiki/Pig_Latin) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
