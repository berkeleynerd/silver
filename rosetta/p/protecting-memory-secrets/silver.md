# Protecting Memory Secrets

**Excluded from Silver: other.** Every check in this program is a slice bound that follows from the input library's contract on Last, so the proofs should discharge automatically. The real erasure guarantee against memory scrapers comes from the admitted wipe operation's specification rather than from proof, so it is listed as an effect, not as a conflict.

## Approach

Main declares a fixed 64-character String buffer and a Natural length, then reads one line from standard input with an admitted Get_Line, rejecting the input visibly if the line is missing or longer than the buffer. It prints Buffer (1 .. Last) with Put_Line, then passes the whole buffer to an admitted Wipe operation that must overwrite it in a way the compiler cannot elide. There is no heap, no access types and no temporary copies, so the secret lives in exactly one stack buffer. About 25 lines.

## Proof obligations to watch

- **index**: Displaying the slice Buffer (1 .. Last) is safe because the admitted line-reading operation guarantees that Last lies in 0 .. Buffer'Last.
- **other**: Flow analysis would flag a final overwrite of a buffer that is never read again as ineffective, so the wipe has to be the admitted library call with a declared effect, not a plain assignment loop.

## Language surface recorded by this assessment

Integers, string indexing and standard input.

## External effects

- **standard input** (allowed): The secret is read as one line from standard input into a fixed-capacity buffer, and an over-long or missing line is rejected with a specified message.
- **console output** (allowed): The program displays the secret, then reports that it has been erased.
- **other** (not allowed): Erasing the secret needs an admitted wipe operation whose specified behavior is an overwrite the compiler cannot remove as a dead store, because plain source cannot guarantee that.

Assessed on 2026-10-15 against page revision 373568 of the [task](https://rosettacode.org/wiki/Protecting_Memory_Secrets) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
