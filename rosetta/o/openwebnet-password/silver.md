# OpenWebNet password

**Candidate: proofs likely to discharge automatically.** Every operation is on a wraparound modular type inside a for loop over the string's own range, so no check depends on a loop-carried fact beyond type ranges, and the only guard is the digit test on each nonce character.

Position 1273 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

The program embeds the password 12345 and the example nonce as constants, holds num1 and num2 in a 32-bit modular type, and runs a for loop over the nonce's own index range with a case statement on each digit character applying the shift, mask and or rules (Shift_Left/Shift_Right with static counts). Non-digit nonce characters are rejected with a specified message, and the final number is converted to text and wrapped as *#...## for Put_Line. About 70 lines.

## Proof obligations to watch

- **range**: Converting each nonce character to a digit is guarded by a '0'..'9' test, and a non-digit nonce is rejected with a visible message.
- **overflow**: All bit arithmetic is on a 32-bit modular type where wraparound is defined, and shift amounts are static constants less than 32.

## Language surface recorded by this assessment

Modular types, characters, string indexing, for loops, case statements, 'Image of scalars, string building and ranged subtypes.

## External effects

- **console output** (allowed): Prints the computed reply line such as *#25280520## with Put_Line.

Assessed on 2026-10-15 against page revision 413820 of the [task](https://rosettacode.org/wiki/OpenWebNet_password) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
