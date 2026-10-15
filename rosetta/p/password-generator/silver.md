# Password generator

**Excluded from Silver: system randomness.** Included. The task needs bounded strings or character arrays for the four character sets, checked integer parsing of the length and count arguments, loops that fill each password, and an explicit guard rejecting a length below 4 or above a documented maximum. A fill method can guarantee one character from each group (for example, filling four positions first and shuffling), so no proof annotations are needed. None of this breaks an Oracle rule; the missing pieces are command-line options and an admitted random source seeded from system entropy.

## Language surface beyond today's Silver

Integers, characters, string operations, arrays, loops and subprograms.

## External effects

- **console output** (allowed): Prints the generated passwords one per line, plus the help text and messages that reject invalid options.
- **arguments** (allowed): Reads the password length, the number of passwords and a help option from the command line, and rejects malformed or out-of-range values with a visible message.
- **system randomness** (not allowed): The task asks for randomness from a system source or library. Passwords that repeat on every run would not meet the task's purpose, so the generator needs a seed from system randomness. A user-supplied seed is optional extra credit.

Assessed on 2026-10-15 against page revision 413839 of the [task](https://rosettacode.org/wiki/Password_generator) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
